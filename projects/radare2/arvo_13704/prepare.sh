#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Nothing to do!

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
# apt deletes a .deb from the cache right after installing it
# (APT::Keep-Downloaded-Packages defaults to false), which breaks a SECOND
# --no-download install in the same script. Keep them.
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
apt-get install -y --download-only pkg-config

# --- prefetch radare2 capstone tarball ---
# shlr/Makefile has `capstone: capstone-$(CS_VER).tar.gz` and downloads that file
# from codeload.github.com (HTTP, so insteadOf cannot rewrite it). Staging the
# tarball makes the download rule a no-op.
SH="$SRC/radare2/shlr"
if [ -d "$SH" ]; then
  apt-get install -y -qq wget
  CSV=$(grep -oE '^CS_VER=[0-9.]+' "$SH/Makefile" | head -1 | cut -d= -f2)
  [ -n "$CSV" ] || CSV=4.0.1
  if [ ! -f "$SH/capstone-$CSV.tar.gz" ]; then
    wget -q -O "$SH/capstone-$CSV.tar.gz" \
      "https://codeload.github.com/aquynh/capstone/tar.gz/$CSV" \
      || echo "WARN: could not prefetch capstone $CSV"
  fi
fi
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
# Stage the .debs outside apt's cache: apt removes them as it installs, so a
# second --no-download install in the same script would find an empty cache.
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true
