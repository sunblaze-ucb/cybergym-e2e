#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Nothing to do!

# --- prefetch git deps (mirror locally, then rewrite https->file so the
#     agent phase resolves clones with no network) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/DavidKorczynski/binary-samples)
( git clone --mirror https://github.com/DavidKorczynski/binary-samples.git /deps/git/github.com/DavidKorczynski/binary-samples 2>/dev/null || git clone --mirror https://github.com/DavidKorczynski/binary-samples /deps/git/github.com/DavidKorczynski/binary-samples ) || echo 'WARN: could not mirror https://github.com/DavidKorczynski/binary-samples'
[ -d /deps/git/github.com/DavidKorczynski/binary-samples ] && ln -sfn /deps/git/github.com/DavidKorczynski/binary-samples /deps/git/github.com/DavidKorczynski/binary-samples.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
