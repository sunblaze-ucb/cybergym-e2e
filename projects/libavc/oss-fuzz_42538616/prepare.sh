#!/usr/bin/env bash

# Install dependencies
apt-get update && apt-get install -y wget cmake

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
# apt deletes a .deb from the cache right after installing it
# (APT::Keep-Downloaded-Packages defaults to false), which breaks a SECOND
# --no-download install in the same script. Keep them.
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
apt-get install -y --download-only unzip

# --- prefetch libavc test resources (test.sh wgets a zip from dl.google.com) ---
apt-get install -y -qq wget
mkdir -p /deps/files
U="https://dl.google.com/android-unittest/media/external/libavc/tests/AvcTestRes-1.0.zip"
[ -f /deps/files/AvcTestRes-1.0.zip ] || wget -q -O /deps/files/AvcTestRes-1.0.zip "$U" \
  || echo "WARN: could not prefetch libavc test resources"
# Stage the .debs outside apt's cache: apt removes them as it installs, so a
# second --no-download install in the same script would find an empty cache.
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true

# --- mirror googletest so the test build needs no network ---
# tests/AvcEncTest.cmake fetches it with
#   GIT_REPOSITORY https://android.googlesource.com/platform/external/googletest
#   GIT_TAG main
# A --mirror clone carries every ref, so "main" still resolves offline.
mkdir -p /deps/git/android.googlesource.com/platform/external
if [ ! -d /deps/git/android.googlesource.com/platform/external/googletest ]; then
  git clone --mirror https://android.googlesource.com/platform/external/googletest \
    /deps/git/android.googlesource.com/platform/external/googletest \
    || echo "WARN: could not mirror googletest"
fi
git config --global --replace-all url."file:///deps/git/android.googlesource.com/".insteadOf "https://android.googlesource.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
