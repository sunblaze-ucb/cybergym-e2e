#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Nothing to do!

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
# apt deletes a .deb from the cache right after installing it
# (APT::Keep-Downloaded-Packages defaults to false), which breaks a SECOND
# --no-download install in the same script. Keep them.
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
apt-get install -y --download-only cmake

# --- prefetch googletest 1.8.0 so the test build needs no network ---
# test.sh forces a download (GOOGLETEST_PATH=/nonexistent) because the system
# googletest is too new for this test code; fetch 1.8.0 here instead. /deps is
# outside /src so it survives validate.py's restore_src().
if [ ! -d /deps/googletest ]; then
  mkdir -p /deps
  git clone --depth 1 --branch release-1.8.0 https://github.com/google/googletest /deps/googletest \
    || echo "WARN: could not prefetch googletest"
fi
# Stage the .debs outside apt's cache: apt removes them as it installs, so a
# second --no-download install in the same script would find an empty cache.
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true
