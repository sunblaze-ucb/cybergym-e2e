#!/usr/bin/env bash

# Reusing CyberGym Image

# --- prefetch git deps ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/google/googletest)
( git clone --mirror https://github.com/google/googletest.git /deps/git/github.com/google/googletest 2>/dev/null || git clone --mirror https://github.com/google/googletest /deps/git/github.com/google/googletest ) || echo 'WARN: mirror failed https://github.com/google/googletest'
[ -d /deps/git/github.com/google/googletest ] && ln -sfn /deps/git/github.com/google/googletest /deps/git/github.com/google/googletest.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
git config --global protocol.file.allow always
