#!/usr/bin/env bash
set -euo pipefail

apt-get update && apt-get install -y zlib1g-dev

# --- prefetch git deps (mirror locally, then rewrite https->file so the
#     agent phase resolves clones with no network) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/AcademySoftwareFoundation/Imath)
( git clone --mirror https://github.com/AcademySoftwareFoundation/Imath.git /deps/git/github.com/AcademySoftwareFoundation/Imath 2>/dev/null || git clone --mirror https://github.com/AcademySoftwareFoundation/Imath /deps/git/github.com/AcademySoftwareFoundation/Imath ) || echo "WARN: could not mirror https://github.com/AcademySoftwareFoundation/Imath"
[ -d /deps/git/github.com/AcademySoftwareFoundation/Imath ] && ln -sfn /deps/git/github.com/AcademySoftwareFoundation/Imath /deps/git/github.com/AcademySoftwareFoundation/Imath.git || true
mkdir -p $(dirname /deps/git/github.com/ebiggers/libdeflate)
( git clone --mirror https://github.com/ebiggers/libdeflate.git /deps/git/github.com/ebiggers/libdeflate 2>/dev/null || git clone --mirror https://github.com/ebiggers/libdeflate /deps/git/github.com/ebiggers/libdeflate ) || echo "WARN: could not mirror https://github.com/ebiggers/libdeflate"
[ -d /deps/git/github.com/ebiggers/libdeflate ] && ln -sfn /deps/git/github.com/ebiggers/libdeflate /deps/git/github.com/ebiggers/libdeflate.git || true
mkdir -p $(dirname /deps/git/github.com/madler/zlib)
( git clone --mirror https://github.com/madler/zlib.git /deps/git/github.com/madler/zlib 2>/dev/null || git clone --mirror https://github.com/madler/zlib /deps/git/github.com/madler/zlib ) || echo "WARN: could not mirror https://github.com/madler/zlib"
[ -d /deps/git/github.com/madler/zlib ] && ln -sfn /deps/git/github.com/madler/zlib /deps/git/github.com/madler/zlib.git || true
git config --global url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always

# --- prefetch openexr bin-test images so test.sh needs no network ---
# src/test/bin/CMakeLists.txt file(DOWNLOAD)s ~16 .exr images from
# raw.githubusercontent.com. file(DOWNLOAD) has no status check there, so
# offline it silently writes empty files and the bin tests fail. Both the repo
# and the tag are CACHE STRINGs, so test.sh can point the repo at a local dir.
CML="$SRC/openexr/src/test/bin/CMakeLists.txt"
if [ -f "$CML" ]; then
  TAG=$(sed -n 's/.*OPENEXR_IMAGES_TAG "\([^"]*\)".*/\1/p' "$CML" | head -1)
  URL=$(sed -n 's|.*OPENEXR_IMAGES_REPO "\([^"]*\)".*|\1|p' "$CML" | head -1)
  DEST="/deps/openexr-images/${TAG}"
  apt-get install -y -qq curl
  awk '/set\(images/{f=1;next} f&&/^[[:space:]]*\)/{exit} f{print $1}' "$CML" |
  while read -r img; do
    [ -n "$img" ] || continue
    mkdir -p "$DEST/$(dirname "$img")"
    [ -s "$DEST/$img" ] || curl -fsSL -o "$DEST/$img" "${URL}/${TAG}/${img}" \
      || echo "WARN: could not prefetch openexr image $img"
  done
  echo "openexr images prefetched: $(find /deps/openexr-images -type f | wc -l)"
fi
