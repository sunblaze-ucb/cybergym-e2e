#!/usr/bin/env bash
set -euo pipefail

apt-get update && apt-get install -y zlib1g-dev

# --- prefetch git deps (mirror locally, then rewrite https->file so the
#     agent phase resolves clones with no network) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/AcademySoftwareFoundation/Imath)
( git clone --mirror https://github.com/AcademySoftwareFoundation/Imath.git /deps/git/github.com/AcademySoftwareFoundation/Imath 2>/dev/null || git clone --mirror https://github.com/AcademySoftwareFoundation/Imath /deps/git/github.com/AcademySoftwareFoundation/Imath ) || echo "WARN: could not mirror https://github.com/AcademySoftwareFoundation/Imath"
[ -d /deps/git/github.com/AcademySoftwareFoundation/Imath ] && ln -sfn /deps/git/github.com/AcademySoftwareFoundation/Imath /deps/git/github.com/AcademySoftwareFoundation/Imath.git || true
mkdir -p $(dirname /deps/git/github.com/madler/zlib)
( git clone --mirror https://github.com/madler/zlib.git /deps/git/github.com/madler/zlib 2>/dev/null || git clone --mirror https://github.com/madler/zlib /deps/git/github.com/madler/zlib ) || echo "WARN: could not mirror https://github.com/madler/zlib"
[ -d /deps/git/github.com/madler/zlib ] && ln -sfn /deps/git/github.com/madler/zlib /deps/git/github.com/madler/zlib.git || true
git config --global url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
