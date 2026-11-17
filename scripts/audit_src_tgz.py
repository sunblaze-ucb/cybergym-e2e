"""Audit src.tgz tar headers for metadata that could point at the vulnerable files.

Every member must have:
  - mtime == 1775001600 (2026-04-01T00:00:00Z), whole seconds
  - uid == gid == 0 and empty user/group names
  - mode 0644 or 0755 (symlinks are exempt)
  - no pax atime/ctime records
This is what scripts/pack.sh writes. Reads headers only (streams through pigz or
gzip); nothing is extracted. Exits 1 if any archive fails or cannot be read.

Usage: python3 scripts/audit_src_tgz.py [-j N] [-v] PATH [PATH ...]
  PATH is a src.tgz or a directory searched recursively for src.tgz.
"""
import argparse
import os
import shutil
import subprocess
import sys
import tarfile
from collections import Counter
from concurrent.futures import ProcessPoolExecutor

EPOCH = 1775001600
MODES = (0o644, 0o755)
EXAMPLES = 3


def violations(m):
    out = []
    if m.mtime != EPOCH:
        out.append(("mtime", m.mtime))
    if m.uid or m.gid:
        out.append(("uid/gid", f"{m.uid}:{m.gid}"))
    if m.uname or m.gname:
        out.append(("uname/gname", f"{m.uname}:{m.gname}"))
    if not m.issym() and m.mode not in MODES:
        out.append(("mode", oct(m.mode)))
    for k in ("atime", "ctime"):
        if k in m.pax_headers:
            out.append((f"pax {k}", m.pax_headers[k]))
    return out


def audit(path):
    """Returns (path, n_members, Counter of violation kinds, examples, error)."""
    gz = shutil.which("pigz") or "gzip"
    p = subprocess.Popen([gz, "-dc", path], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    n, kinds, examples, err = 0, Counter(), [], None
    try:
        with tarfile.open(fileobj=p.stdout, mode="r|") as tf:
            for m in tf:
                n += 1
                for kind, val in violations(m):
                    kinds[kind] += 1
                    if kinds[kind] <= EXAMPLES:
                        examples.append(f"{kind}={val} {m.name}")
        # tarfile stops at the end-of-archive marker; drain the padding after it so the
        # decompressor reaches the gzip trailer (CRC check) instead of dying on SIGPIPE.
        while p.stdout.read(1 << 20):
            pass
    except Exception as e:  # truncated or corrupt archive
        err = repr(e)[:300]
    finally:
        p.stdout.close()
        stderr = p.stderr.read().decode(errors="replace").strip()
        if p.wait() and not err:
            err = f"{gz} exit {p.returncode}: {stderr[:300]}"
    if not err and n == 0:
        err = "no members"
    return path, n, kinds, examples, err


def find(paths):
    out = []
    for p in paths:
        if os.path.isdir(p):
            for root, _, files in os.walk(p, followlinks=True):
                out += [os.path.join(root, f) for f in files if f == "src.tgz"]
        elif os.path.isfile(p):
            out.append(p)
        else:
            sys.exit(f"not found: {p}")
    return sorted(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("paths", nargs="+")
    ap.add_argument("-j", "--jobs", type=int, default=os.cpu_count())
    ap.add_argument("-v", "--verbose", action="store_true", help="also print passing archives")
    a = ap.parse_args()
    files = find(a.paths)
    if not files:
        sys.exit("no src.tgz found")
    # Largest first so the slowest archives do not start last.
    files.sort(key=lambda f: -os.path.getsize(f))
    bad = members = 0
    with ProcessPoolExecutor(min(a.jobs, len(files))) as ex:
        for path, n, kinds, examples, err in ex.map(audit, files):
            members += n
            if err or kinds:
                bad += 1
                what = err or ", ".join(f"{k}: {v}" for k, v in sorted(kinds.items()))
                print(f"FAIL {path} ({n} members) {what}", flush=True)
                for e in examples:
                    print(f"     {e}")
            elif a.verbose:
                print(f"OK   {path} ({n} members)", flush=True)
    print(f"{len(files) - bad}/{len(files)} archives pass, {members} members checked")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
