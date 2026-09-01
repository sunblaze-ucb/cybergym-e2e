"""
Domain-allowlist proxy for agent containers.

Runs a Squid forward proxy that bridges between an **internal** Docker network
(no internet route) and the default bridge (internet).  Agent containers sit
on the internal network and can *only* reach the proxy — even if a program
ignores HTTP_PROXY, direct connections fail because there is no route out.

Architecture
------------
    Agent ──(cybergym-internal, no internet)──▶ Squid ──(bridge)──▶ Internet
                                                       filtered by domain

Two proxies, two phases
-----------------------
The *run* proxy (this default) enforces an API-only domain allowlist and is
what the agent sees while it runs. A second *install* proxy
(``FirewallProxyManager.for_install()``) sits on its own internal network
(``cybergym-install``) and forwards to **any** destination — it exists only for
the pre-agent install phase, where the container needs unrestricted network
access to fetch packages. The evaluator disconnects the container from the
install network before the agent runs, so the agent has no route to it.

    # Run proxy:     python -m cybergym.firewall start --which run
    # Install proxy: python -m cybergym.firewall start --which install
    # Both:          python -m cybergym.firewall start --which both

Usage
-----
    from cybergym.firewall import FirewallProxyManager, load_allowlist

    proxy = FirewallProxyManager(
        allowed_domains=load_allowlist("allowlist.txt"),
    )
    proxy.start()

    # The host is reachable at proxy.host_gateway (internal bridge gateway).
    # This IP is auto-added to NO_PROXY so containers bypass the proxy for it.
    server_url = f"http://{proxy.host_gateway}:13338"

    # Create agent container on the internal network:
    container = client.containers.run(
        image=..., detach=True,
        network=proxy.network_name,
    )

    # Merge proxy env vars into docker exec:
    envs.update(proxy.env_vars())

    # Cleanup (optional — proxy is shared across runs):
    proxy.stop()
"""

import argparse
import io
import json
import logging
import tarfile
import time
from pathlib import Path

import docker
from docker.errors import APIError, NotFound

logger = logging.getLogger(__name__)

PROXY_CONTAINER_NAME = "cybergym-proxy"
PROXY_IMAGE = "ubuntu/squid:latest"
PROXY_PORT = 3128
INTERNAL_NETWORK = "cybergym-internal"

# Install proxy: a second, allow-all proxy on its own internal network. Used
# only during the pre-agent install phase. The agent container is disconnected
# from this network before the agent runs, so it has no route to this proxy
# during the agent phase (where only the run proxy's API allowlist applies).
INSTALL_PROXY_CONTAINER_NAME = "cybergym-install-proxy"
INSTALL_NETWORK = "cybergym-install"

DEFAULT_ALLOWLIST_PATH = Path(__file__).with_name("default_allowlist.txt")

DOMAIN_ALLOWLIST_CONTAINER_PATH = "/etc/squid/allowed_domains.txt"
IP_ALLOWLIST_CONTAINER_PATH = "/etc/squid/allowed_ips.txt"

SQUID_CONF_TEMPLATE = """\
# --- CyberGym domain-allowlist proxy ---

acl SSL_ports port 443 {extra_ports}
acl Safe_ports port 80 443 {extra_ports}
acl CONNECT method CONNECT

# Allowed destinations — loaded from external files
acl allowed_domains dstdomain "{domain_allowlist_path}"
{ip_acl}

# Rules
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow CONNECT allowed_domains
{ip_connect_rule}
http_access allow allowed_domains
{ip_rule}
http_access deny all

http_port {port}

# Disable disk cache
cache deny all

# Logging (Squid runs as user 'proxy' which cannot write to /dev/stdout)
access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log
"""

ALLOW_ALL_SQUID_CONF_TEMPLATE = """\
# --- CyberGym install proxy (allow-all) ---
# Forwards to any destination. Used only during the install phase; the agent
# container is disconnected from this proxy's network before the agent runs.

acl SSL_ports port 1-65535
acl Safe_ports port 1-65535
acl CONNECT method CONNECT

http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow all

http_port {port}

# Disable disk cache
cache deny all

# Logging (Squid runs as user 'proxy' which cannot write to /dev/stdout)
access_log /var/log/squid/access.log
cache_log /var/log/squid/cache.log
"""


def load_allowlist(path: str | Path) -> list[str]:
    """Load domain allowlist from a text file.

    The file should contain one domain per line in Squid ``dstdomain``
    format — a leading dot means "match this domain and all subdomains"
    (e.g. ``.pypi.org``).  Empty lines and lines starting with ``#``
    are ignored.

    Returns:
        List of domain strings, preserved exactly as written in the file.
    """
    domains: list[str] = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            domains.append(line)
    return domains


class FirewallProxyManager:
    """Manages a Squid proxy container with network-level enforcement."""

    def __init__(
        self,
        allowlist_path: str | Path | None = None,
        extra_domains: list[str] | None = None,
        ip_allowlist_path: str | Path | None = None,
        extra_ips: list[str] | None = None,
        no_proxy: list[str] | None = None,
        proxy_image: str = PROXY_IMAGE,
        proxy_port: int = PROXY_PORT,
        container_name: str = PROXY_CONTAINER_NAME,
        network_name: str = INTERNAL_NETWORK,
        allow_all: bool = False,
    ):
        self.allow_all = allow_all
        if allow_all:
            # No allowlist needed — the proxy forwards to any destination.
            self.allowlist_path = (
                Path(allowlist_path).resolve() if allowlist_path else None
            )
        else:
            self.allowlist_path = Path(
                allowlist_path or DEFAULT_ALLOWLIST_PATH
            ).resolve()
            if not self.allowlist_path.is_file():
                raise FileNotFoundError(
                    f"Allowlist file not found: {self.allowlist_path}"
                )
        self.extra_domains = extra_domains or []
        self.ip_allowlist_path = (
            Path(ip_allowlist_path).resolve() if ip_allowlist_path else None
        )
        if self.ip_allowlist_path and not self.ip_allowlist_path.is_file():
            raise FileNotFoundError(
                f"IP allowlist file not found: {self.ip_allowlist_path}"
            )
        self.extra_ips = extra_ips or []
        self.no_proxy = no_proxy or []
        self.proxy_image = proxy_image
        self.proxy_port = proxy_port
        self.container_name = container_name
        self.network_name = network_name
        self._client = docker.from_env()

    @classmethod
    def for_install(cls, **kwargs) -> "FirewallProxyManager":
        """Build an allow-all install proxy on its own internal network.

        Used for the pre-agent install phase, where the container needs
        unrestricted network access to fetch packages. The agent container is
        disconnected from this network before the agent runs.
        """
        kwargs.setdefault("container_name", INSTALL_PROXY_CONTAINER_NAME)
        kwargs.setdefault("network_name", INSTALL_NETWORK)
        return cls(allow_all=True, **kwargs)

    # -- public API ----------------------------------------------------------

    @property
    def proxy_url(self) -> str:
        return f"http://{self.container_name}:{self.proxy_port}"

    def env_vars(self) -> dict[str, str]:
        """Return env-var dict suitable for ``docker exec -e``."""
        return {
            "HTTP_PROXY": self.proxy_url,
            "HTTPS_PROXY": self.proxy_url,
            "NO_PROXY": ",".join(self.no_proxy),
            "http_proxy": self.proxy_url,
            "https_proxy": self.proxy_url,
            "no_proxy": ",".join(self.no_proxy),
        }

    @property
    def host_gateway(self) -> str:
        """Return the host gateway IP on the internal network.

        Containers on the internal network can reach the host at this IP
        without going through the proxy.  Available after ``start()``.
        """
        net = self._client.networks.get(self.network_name)
        configs = net.attrs.get("IPAM", {}).get("Config", [])
        if configs and configs[0].get("Gateway"):
            return configs[0]["Gateway"]
        raise RuntimeError(f"No gateway found for network {self.network_name}")

    def connect(self) -> None:
        """Connect to an already-running proxy without starting anything.

        Populates ``no_proxy`` with the host gateway and localhost so that
        ``env_vars()`` returns usable values.  Raises if the network or
        proxy container does not exist.
        """
        # Verify infrastructure is up
        self._client.networks.get(self.network_name)
        c = self._client.containers.get(self.container_name)
        if c.status != "running":
            raise RuntimeError(
                f"Proxy container {self.container_name} exists but is not running "
                f"(status: {c.status})"
            )

        gw = self.host_gateway
        if gw not in self.no_proxy:
            self.no_proxy.append(gw)
        for local in ["localhost", "127.0.0.1"]:
            if local not in self.no_proxy:
                self.no_proxy.append(local)

        logger.info(
            "Connected to existing proxy: url=%s network=%s",
            self.proxy_url,
            self.network_name,
        )

    def start(self) -> None:
        """Ensure the internal network and proxy container are running."""
        self._ensure_network()
        # NO_PROXY only: containers bypass the proxy for host traffic, but the
        # gateway is deliberately NOT added to the IP allowlist. Allowlisting it
        # would let the proxy CONNECT to any host port, and would flip
        # extra_ports to 1-65535, nullifying the 443-only restriction.
        gw = self.host_gateway
        if gw not in self.no_proxy:
            self.no_proxy.append(gw)

        for local in ["localhost", "127.0.0.1"]:
            if local not in self.no_proxy:
                self.no_proxy.append(local)

        self._ensure_proxy()

    def update(self) -> None:
        """Restart the proxy container with the current configuration.

        Useful after modifying the allowlist files on the host. The new
        container gets fresh copies of all config files.
        The internal network is preserved so other containers stay connected.
        """
        self.stop()
        self._ensure_network()
        self._ensure_proxy()

    def stop(self) -> None:
        """Stop and remove the proxy container (network is left for reuse)."""
        try:
            c = self._client.containers.get(self.container_name)
            c.remove(force=True)
            logger.info("Removed proxy container %s", self.container_name)
        except NotFound:
            pass

    def stop_all(self) -> None:
        """Stop proxy and remove the internal network (disconnects lingering containers)."""
        self.stop()
        try:
            net = self._client.networks.get(self.network_name)
            net.reload()
            for c in net.containers:
                logger.info("Disconnecting %s from %s", c.name, self.network_name)
                net.disconnect(c, force=True)
            net.remove()
            logger.info("Removed network %s", self.network_name)
        except NotFound:
            pass

    def status(self) -> dict:
        """Return a dict describing the current infrastructure state."""
        info: dict = {"network": None, "proxy": None}

        try:
            net = self._client.networks.get(self.network_name)
            net.reload()
            info["network"] = {
                "name": self.network_name,
                "internal": net.attrs.get("Internal", False),
                "containers": [c.name for c in net.containers],
            }
        except NotFound:
            pass

        try:
            c = self._client.containers.get(self.container_name)
            c.reload()
            health = c.attrs.get("State", {}).get("Health", {}).get("Status", "unknown")
            info["proxy"] = {
                "name": self.container_name,
                "status": c.status,
                "health": health,
            }
        except NotFound:
            pass

        return info

    # -- internals -----------------------------------------------------------

    def _ensure_network(self) -> None:
        try:
            net = self._client.networks.get(self.network_name)
            if not net.attrs.get("Internal", False):
                raise RuntimeError(
                    f"Network {self.network_name!r} exists but is not internal. "
                    "An external network cannot enforce egress isolation. "
                    "Remove it and let the proxy recreate it, or use a different name."
                )
        except NotFound:
            # internal=True  →  no default route to the internet
            self._client.networks.create(
                self.network_name, driver="bridge", internal=True
            )
            logger.info("Created internal network %s", self.network_name)

    def _ensure_proxy(self) -> None:
        # Already running?
        try:
            c = self._client.containers.get(self.container_name)
            if c.status == "running":
                logger.info("Proxy container already running")
                return
            c.remove(force=True)
        except NotFound:
            pass

        # Create container (stopped), copy config files in, then start.
        # This avoids bind-mounts so the container is self-contained.
        try:
            proxy = self._client.containers.create(
                image=self.proxy_image,
                name=self.container_name,
            )

            # Copy the squid config into the container
            self._put_file(proxy, "/etc/squid/squid.conf", self._generate_squid_conf())

            # Allowlist files are only meaningful for the filtering proxy.
            if not self.allow_all:
                domain_content = self._build_allowlist(
                    self.allowlist_path, self.extra_domains
                )
                ip_content = self._build_allowlist(
                    self.ip_allowlist_path, self.extra_ips
                )
                self._put_file(proxy, DOMAIN_ALLOWLIST_CONTAINER_PATH, domain_content)
                if ip_content:
                    self._put_file(proxy, IP_ALLOWLIST_CONTAINER_PATH, ip_content)

            proxy.start()

            # Connect proxy to the internal network so agents can reach it
            net = self._client.networks.get(self.network_name)
            net.connect(proxy)
            self._wait_ready(proxy)
            logger.info("Started proxy container %s", self.container_name)
        except APIError as e:
            if "Conflict" in str(e):
                logger.info("Proxy container created by another thread")
            else:
                raise

    @staticmethod
    def _put_file(container, path: str, content: str) -> None:
        """Write *content* into *path* inside a (possibly stopped) container."""
        data = content.encode()
        buf = io.BytesIO()
        with tarfile.open(fileobj=buf, mode="w") as tar:
            info = tarfile.TarInfo(name=path.rsplit("/", 1)[-1])
            info.size = len(data)
            tar.addfile(info, io.BytesIO(data))
        buf.seek(0)
        container.put_archive(str(Path(path).parent), buf)

    def _wait_ready(self, proxy, timeout: int = 30) -> None:
        """Block until Squid is accepting connections."""
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            container = self._client.containers.get(proxy.id)
            ret = container.exec_run(
                ["bash", "-c", f"echo > /dev/tcp/127.0.0.1/{self.proxy_port}"]
            )
            if ret.exit_code == 0:
                return
            time.sleep(0.5)
        raise TimeoutError(f"Squid not ready after {timeout}s")

    @staticmethod
    def _build_allowlist(file_path: Path | None, extra_entries: list[str]) -> str:
        """Merge a file and extra entries into a single allowlist string."""
        lines: list[str] = []
        if file_path:
            lines.append(file_path.read_text().rstrip("\n"))
        if extra_entries:
            lines.extend(extra_entries)
        return "\n".join(lines) + "\n" if lines else ""

    def _has_ips(self) -> bool:
        return bool(self.ip_allowlist_path or self.extra_ips)

    def _generate_squid_conf(self) -> str:
        if self.allow_all:
            return ALLOW_ALL_SQUID_CONF_TEMPLATE.format(port=self.proxy_port)

        ip_acl = ""
        ip_rule = ""
        ip_connect_rule = ""
        if self._has_ips():
            ip_acl = f'acl allowed_ips dst "{IP_ALLOWLIST_CONTAINER_PATH}"'
            ip_rule = "http_access allow allowed_ips"
            ip_connect_rule = "http_access allow CONNECT allowed_ips"

        # Allow any port for IP-based destinations
        extra_ports = "1-65535" if self._has_ips() else ""

        return SQUID_CONF_TEMPLATE.format(
            domain_allowlist_path=DOMAIN_ALLOWLIST_CONTAINER_PATH,
            ip_acl=ip_acl,
            ip_rule=ip_rule,
            ip_connect_rule=ip_connect_rule,
            extra_ports=extra_ports,
            port=self.proxy_port,
        )


# ======================================================================
# CLI
# ======================================================================


def _build_manager(which: str, args: argparse.Namespace) -> "FirewallProxyManager":
    """Construct the manager for one proxy target ('run' or 'install')."""
    if which == "install":
        # The install proxy is allow-all; domain/IP allowlist args don't apply.
        return FirewallProxyManager.for_install()

    kwargs: dict = {}
    if getattr(args, "allowlist", None):
        kwargs["allowlist_path"] = args.allowlist
    if getattr(args, "domain", None):
        kwargs["extra_domains"] = args.domain
    if getattr(args, "ip_allowlist", None):
        kwargs["ip_allowlist_path"] = args.ip_allowlist
    if getattr(args, "ip", None):
        kwargs["extra_ips"] = args.ip
    return FirewallProxyManager(**kwargs)


def _resolve_targets(which: str) -> list[str]:
    return ["run", "install"] if which == "both" else [which]


def main():
    parser = argparse.ArgumentParser(
        description="Manage the CyberGym proxy infrastructure.",
    )
    sub = parser.add_subparsers(dest="action", required=True)

    def _add_which(p):
        p.add_argument(
            "--which",
            choices=["run", "install", "both"],
            default="run",
            help=(
                "Which proxy to manage: 'run' (API-only allowlist, default), "
                "'install' (allow-all install proxy), or 'both'."
            ),
        )

    # Shared arguments for start/update
    for p in [
        sub.add_parser("start", help="Create network and start proxy"),
        sub.add_parser(
            "update", help="Restart proxy with current config (network preserved)"
        ),
    ]:
        _add_which(p)
        p.add_argument(
            "--allowlist",
            type=Path,
            help="Domain allowlist file (default: built-in list). Run proxy only.",
        )
        p.add_argument(
            "--domain",
            action="append",
            help="Extra allowed domain (run proxy only)",
        )
        p.add_argument(
            "--ip-allowlist",
            type=Path,
            help="IP allowlist file (run proxy only)",
        )
        p.add_argument(
            "--ip",
            action="append",
            help="Extra allowed IP/CIDR (run proxy only)",
        )

    _add_which(sub.add_parser("stop", help="Stop proxy container"))
    _add_which(sub.add_parser("stop-all", help="Stop proxy and remove network"))
    _add_which(sub.add_parser("status", help="Show infrastructure state"))

    args = parser.parse_args()
    logging.basicConfig(format="%(asctime)s [%(name)s] %(message)s", level=logging.INFO)

    for which in _resolve_targets(args.which):
        mgr = _build_manager(which, args)
        match args.action:
            case "start":
                mgr.start()
                logger.info(
                    "Proxy ready  which=%s  url=%s  network=%s  host_gateway=%s",
                    which,
                    mgr.proxy_url,
                    mgr.network_name,
                    mgr.host_gateway,
                )
            case "update":
                mgr.update()
                logger.info(
                    "Proxy updated  which=%s  url=%s  allowlist=%s",
                    which,
                    mgr.proxy_url,
                    mgr.allowlist_path,
                )
            case "stop":
                mgr.stop()
            case "stop-all":
                mgr.stop_all()
            case "status":
                print(json.dumps({which: mgr.status()}, indent=2))


if __name__ == "__main__":
    main()
