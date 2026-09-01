#!/usr/bin/env bash

# Install dependencies
apt-get update && apt-get install -y wget cmake

# --- prefetch git deps (mirror locally, then rewrite https->file so the
#     agent phase resolves clones with no network) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/google/benchmark)
( git clone --mirror https://github.com/google/benchmark.git /deps/git/github.com/google/benchmark 2>/dev/null || git clone --mirror https://github.com/google/benchmark /deps/git/github.com/google/benchmark ) || echo "WARN: could not mirror https://github.com/google/benchmark"
[ -d /deps/git/github.com/google/benchmark ] && ln -sfn /deps/git/github.com/google/benchmark /deps/git/github.com/google/benchmark.git || true
mkdir -p $(dirname /deps/git/github.com/google/googletest)
( git clone --mirror https://github.com/google/googletest.git /deps/git/github.com/google/googletest 2>/dev/null || git clone --mirror https://github.com/google/googletest /deps/git/github.com/google/googletest ) || echo "WARN: could not mirror https://github.com/google/googletest"
[ -d /deps/git/github.com/google/googletest ] && ln -sfn /deps/git/github.com/google/googletest /deps/git/github.com/google/googletest.git || true
mkdir -p $(dirname /deps/git/github.com/libjpeg-turbo/libjpeg-turbo)
( git clone --mirror https://github.com/libjpeg-turbo/libjpeg-turbo.git /deps/git/github.com/libjpeg-turbo/libjpeg-turbo 2>/dev/null || git clone --mirror https://github.com/libjpeg-turbo/libjpeg-turbo /deps/git/github.com/libjpeg-turbo/libjpeg-turbo ) || echo "WARN: could not mirror https://github.com/libjpeg-turbo/libjpeg-turbo"
[ -d /deps/git/github.com/libjpeg-turbo/libjpeg-turbo ] && ln -sfn /deps/git/github.com/libjpeg-turbo/libjpeg-turbo /deps/git/github.com/libjpeg-turbo/libjpeg-turbo.git || true
git config --global url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
