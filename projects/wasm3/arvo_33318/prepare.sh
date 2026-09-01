#!/usr/bin/env bash
set -euo pipefail

# Add any additional dependency installation commands here

# --- prefetch uvwasi so test.sh's `cmake .` needs no network ---
# CMakeLists.txt FetchContent_Declare's uvwasi from github when BUILD_WASI=uvwasi
# (the default that test.sh's bare `cmake .` selects). compile.sh does not hit
# this path, which is why only test.sh failed. Mirror it locally and rewrite the
# URL; /deps is outside /src so it survives validate.py's restore_src().
mkdir -p /deps/git/github.com/vshymanskyy
UVW=/deps/git/github.com/vshymanskyy/uvwasi.git
if [ ! -d "$UVW" ]; then
  git clone --mirror https://github.com/vshymanskyy/uvwasi.git "$UVW" \
    || echo "WARN: could not mirror uvwasi"
fi
# The pinned GIT_TAG is a bare sha that is NOT reachable from any branch or tag,
# so a --mirror clone does not carry it (github serves it only on direct request).
# Fetch it explicitly and anchor it to a ref so the local mirror can serve it.
if [ -d "$UVW" ]; then
  SHA=$(sed -n 's/.*GIT_TAG[[:space:]]\+\([0-9a-f]\{40\}\).*/\1/p' "$SRC/wasm3/CMakeLists.txt" | head -1)
  if [ -n "$SHA" ] && ! git -C "$UVW" cat-file -e "$SHA^{commit}" 2>/dev/null; then
    git -C "$UVW" fetch origin "$SHA" \
      && git -C "$UVW" update-ref "refs/heads/pinned-$SHA" "$SHA" \
      || echo "WARN: could not pin uvwasi $SHA"
  fi
fi
# uvwasi in turn FetchContent_Populate()s libuv, pinned the same way. Read that
# pin straight out of the uvwasi mirror so it stays correct if the tag changes.
mkdir -p /deps/git/github.com/libuv
LUV=/deps/git/github.com/libuv/libuv.git
if [ ! -d "$LUV" ]; then
  git clone --mirror https://github.com/libuv/libuv.git "$LUV" || echo "WARN: could not mirror libuv"
fi
if [ -d "$LUV" ] && [ -n "${SHA:-}" ]; then
  LSHA=$(git -C "$UVW" show "$SHA:CMakeLists.txt" 2>/dev/null |
         sed -n 's/.*GIT_TAG[[:space:]]\+\([0-9a-f]\{40\}\).*/\1/p' | head -1)
  if [ -n "$LSHA" ] && ! git -C "$LUV" cat-file -e "$LSHA^{commit}" 2>/dev/null; then
    git -C "$LUV" fetch origin "$LSHA" \
      && git -C "$LUV" update-ref "refs/heads/pinned-$LSHA" "$LSHA" \
      || echo "WARN: could not pin libuv $LSHA"
  fi
fi

git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always

# --- prefetch the WebAssembly spec testsuite so test.sh needs no network ---
# test/run-spec-test.py urlopen()s
#   https://github.com/wasm3/wasm-core-testsuite/archive/<spec>.zip
# but only when its cache dir .spec-<spec> is absent. Populate that dir here,
# reusing the script's own version default and extraction layout. It lives under
# /src, so it is captured in the snapshot and restored for every validation run.
python3 - "$SRC/wasm3/test" <<'SPECEOF' || echo "WARN: could not prefetch wasm3 spec testsuite"
import os, pathlib, re, sys
from io import BytesIO
from zipfile import ZipFile
from urllib.request import urlopen

testdir = sys.argv[1]
src = open(os.path.join(testdir, "run-spec-test.py")).read()
spec = re.search(r'"--spec",\s*default="([^"]+)"', src).group(1)

def safe_fn(fn):                       # verbatim from run-spec-test.py
    keep = (' ', '.', '_', '-')
    return "".join(c for c in fn if c.isalnum() or c in keep).strip()

# ZipFile.extract() strips a leading slash from the member name, so an absolute
# target silently lands under the cwd instead. Work from testdir with relative
# paths, exactly as run-spec-test.py itself does.
os.chdir(testdir)
spec_dir = os.path.join(".", ".spec-" + safe_fn(spec))
if os.path.isdir(spec_dir) and any(os.scandir(spec_dir)):
    print("wasm3 spec testsuite already present"); sys.exit(0)

url = f"https://github.com/wasm3/wasm-core-testsuite/archive/{spec}.zip"
print("prefetching", url)
with ZipFile(BytesIO(urlopen(url).read())) as z:
    for zi in z.infolist():
        if re.match(r".*-.*/.*/.*(\.wasm|\.json)", zi.filename):
            parts = pathlib.Path(zi.filename).parts
            newpath = str(pathlib.Path(*parts[1:-1]))
            newfn = str(pathlib.Path(*parts[-1:]))
            os.makedirs(os.path.join(spec_dir, newpath), exist_ok=True)
            zi.filename = os.path.join(spec_dir, newpath, newfn)
            z.extract(zi)
n = sum(len(f) for _, _, f in os.walk(spec_dir))
print(f"wasm3 spec testsuite prefetched: {n} files in {spec_dir}")
if n == 0:
    raise SystemExit("prefetch produced no files")
SPECEOF
