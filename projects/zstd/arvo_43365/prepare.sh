#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Nothing to do!

# --- prefetch git deps (mirror locally, then rewrite https->file so the
#     agent phase resolves clones with no network) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/google/googletest)
( git clone --mirror https://github.com/google/googletest.git /deps/git/github.com/google/googletest 2>/dev/null || git clone --mirror https://github.com/google/googletest /deps/git/github.com/google/googletest ) || echo 'WARN: could not mirror https://github.com/google/googletest'
[ -d /deps/git/github.com/google/googletest ] && ln -sfn /deps/git/github.com/google/googletest /deps/git/github.com/google/googletest.git || true
mkdir -p $(dirname /deps/git/github.com/lz4/lz4)
( git clone --mirror https://github.com/lz4/lz4.git /deps/git/github.com/lz4/lz4 2>/dev/null || git clone --mirror https://github.com/lz4/lz4 /deps/git/github.com/lz4/lz4 ) || echo 'WARN: could not mirror https://github.com/lz4/lz4'
[ -d /deps/git/github.com/lz4/lz4 ] && ln -sfn /deps/git/github.com/lz4/lz4 /deps/git/github.com/lz4/lz4.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"

# --- prefetch zstd seed corpora (downloaded over HTTP at build time; the agent
#     phase cannot reach the corpora host, and `make` skips existing files) ---
if [ -d "$SRC/zstd/tests/fuzz" ]; then
  ( cd "$SRC/zstd/tests/fuzz" && make seedcorpora ) \
    || echo "WARN: zstd seed corpora prefetch failed"
fi
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
