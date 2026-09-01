#!/usr/bin/env bash
set -euo pipefail

# Install libtiff for compare_images test utility
apt-get update && apt-get install -y libtiff-dev libpng-dev

# Note: openjpeg-data is cloned by build.sh into 'data' directory

# --- prefetch git deps (mirror locally, then rewrite https->file so the
#     agent phase resolves clones with no network) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/uclouvain/openjpeg)
( git clone --mirror https://github.com/uclouvain/openjpeg.git /deps/git/github.com/uclouvain/openjpeg 2>/dev/null || git clone --mirror https://github.com/uclouvain/openjpeg /deps/git/github.com/uclouvain/openjpeg ) || echo 'WARN: could not mirror https://github.com/uclouvain/openjpeg'
[ -d /deps/git/github.com/uclouvain/openjpeg ] && ln -sfn /deps/git/github.com/uclouvain/openjpeg /deps/git/github.com/uclouvain/openjpeg.git || true
mkdir -p $(dirname /deps/git/github.com/uclouvain/openjpeg-data)
( git clone --mirror https://github.com/uclouvain/openjpeg-data.git /deps/git/github.com/uclouvain/openjpeg-data 2>/dev/null || git clone --mirror https://github.com/uclouvain/openjpeg-data /deps/git/github.com/uclouvain/openjpeg-data ) || echo 'WARN: could not mirror https://github.com/uclouvain/openjpeg-data'
[ -d /deps/git/github.com/uclouvain/openjpeg-data ] && ln -sfn /deps/git/github.com/uclouvain/openjpeg-data /deps/git/github.com/uclouvain/openjpeg-data.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
