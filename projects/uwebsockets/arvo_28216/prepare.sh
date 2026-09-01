#!/usr/bin/env bash
set -euo pipefail

apt-get update

# --- prefetch git deps (mirror locally, then rewrite https->file) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/madler/zlib)
( git clone --mirror https://github.com/madler/zlib.git /deps/git/github.com/madler/zlib 2>/dev/null || git clone --mirror https://github.com/madler/zlib /deps/git/github.com/madler/zlib ) || echo 'WARN: could not mirror https://github.com/madler/zlib'
[ -d /deps/git/github.com/madler/zlib ] && ln -sfn /deps/git/github.com/madler/zlib /deps/git/github.com/madler/zlib.git || true
mkdir -p $(dirname /deps/git/github.com/alexhultman/zlib)
( git clone --mirror https://github.com/alexhultman/zlib.git /deps/git/github.com/alexhultman/zlib 2>/dev/null || git clone --mirror https://github.com/alexhultman/zlib /deps/git/github.com/alexhultman/zlib ) || echo 'WARN: could not mirror https://github.com/alexhultman/zlib'
[ -d /deps/git/github.com/alexhultman/zlib ] && ln -sfn /deps/git/github.com/alexhultman/zlib /deps/git/github.com/alexhultman/zlib.git || true
mkdir -p $(dirname /deps/git/github.com/google/googletest)
( git clone --mirror https://github.com/google/googletest.git /deps/git/github.com/google/googletest 2>/dev/null || git clone --mirror https://github.com/google/googletest /deps/git/github.com/google/googletest ) || echo 'WARN: could not mirror https://github.com/google/googletest'
[ -d /deps/git/github.com/google/googletest ] && ln -sfn /deps/git/github.com/google/googletest /deps/git/github.com/google/googletest.git || true
mkdir -p $(dirname /deps/git/github.com/litespeedtech/lsquic)
( git clone --mirror https://github.com/litespeedtech/lsquic.git /deps/git/github.com/litespeedtech/lsquic 2>/dev/null || git clone --mirror https://github.com/litespeedtech/lsquic /deps/git/github.com/litespeedtech/lsquic ) || echo 'WARN: could not mirror https://github.com/litespeedtech/lsquic'
[ -d /deps/git/github.com/litespeedtech/lsquic ] && ln -sfn /deps/git/github.com/litespeedtech/lsquic /deps/git/github.com/litespeedtech/lsquic.git || true
mkdir -p $(dirname /deps/git/github.com/uNetworking/uWebSockets)
( git clone --mirror https://github.com/uNetworking/uWebSockets.git /deps/git/github.com/uNetworking/uWebSockets 2>/dev/null || git clone --mirror https://github.com/uNetworking/uWebSockets /deps/git/github.com/uNetworking/uWebSockets ) || echo 'WARN: could not mirror https://github.com/uNetworking/uWebSockets'
[ -d /deps/git/github.com/uNetworking/uWebSockets ] && ln -sfn /deps/git/github.com/uNetworking/uWebSockets /deps/git/github.com/uNetworking/uWebSockets.git || true
mkdir -p $(dirname /deps/git/github.com/uNetworking/uSockets)
( git clone --mirror https://github.com/uNetworking/uSockets.git /deps/git/github.com/uNetworking/uSockets 2>/dev/null || git clone --mirror https://github.com/uNetworking/uSockets /deps/git/github.com/uNetworking/uSockets ) || echo 'WARN: could not mirror https://github.com/uNetworking/uSockets'
[ -d /deps/git/github.com/uNetworking/uSockets ] && ln -sfn /deps/git/github.com/uNetworking/uSockets /deps/git/github.com/uNetworking/uSockets.git || true
mkdir -p $(dirname /deps/git/github.com/uNetworking/libEpollFuzzer)
( git clone --mirror https://github.com/uNetworking/libEpollFuzzer.git /deps/git/github.com/uNetworking/libEpollFuzzer 2>/dev/null || git clone --mirror https://github.com/uNetworking/libEpollFuzzer /deps/git/github.com/uNetworking/libEpollFuzzer ) || echo 'WARN: could not mirror https://github.com/uNetworking/libEpollFuzzer'
[ -d /deps/git/github.com/uNetworking/libEpollFuzzer ] && ln -sfn /deps/git/github.com/uNetworking/libEpollFuzzer /deps/git/github.com/uNetworking/libEpollFuzzer.git || true
mkdir -p $(dirname /deps/git/boringssl.googlesource.com/boringssl)
( git clone --mirror https://boringssl.googlesource.com/boringssl.git /deps/git/boringssl.googlesource.com/boringssl 2>/dev/null || git clone --mirror https://boringssl.googlesource.com/boringssl /deps/git/boringssl.googlesource.com/boringssl ) || echo 'WARN: could not mirror https://boringssl.googlesource.com/boringssl'
[ -d /deps/git/boringssl.googlesource.com/boringssl ] && ln -sfn /deps/git/boringssl.googlesource.com/boringssl /deps/git/boringssl.googlesource.com/boringssl.git || true
git config --global url."file:///deps/git/boringssl.googlesource.com/".insteadOf "https://boringssl.googlesource.com/"
git config --global url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
