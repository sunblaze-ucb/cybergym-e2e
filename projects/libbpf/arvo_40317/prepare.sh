#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Nothing to do!

# --- prefetch git:// deps (install phase runs on the default bridge, so the
#     git protocol on port 9418 is reachable here but not in the agent phase) ---
mkdir -p /deps/git/sourceware.org/git
if [ ! -d /deps/git/sourceware.org/git/elfutils ]; then
  git clone --mirror git://sourceware.org/git/elfutils.git /deps/git/sourceware.org/git/elfutils \
    || git clone --mirror https://sourceware.org/git/elfutils.git /deps/git/sourceware.org/git/elfutils \
    || echo "WARN: could not mirror elfutils"
fi
[ -d /deps/git/sourceware.org/git/elfutils ] && \
  ln -sfn /deps/git/sourceware.org/git/elfutils /deps/git/sourceware.org/git/elfutils.git || true
# --add: plain `git config url.X.insteadOf Y` REPLACES, so a second protocol
# would silently drop the first.
git config --global --replace-all url."file:///deps/git/sourceware.org/git/".insteadOf "git://sourceware.org/git/"
git config --global --add         url."file:///deps/git/sourceware.org/git/".insteadOf "https://sourceware.org/git/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
