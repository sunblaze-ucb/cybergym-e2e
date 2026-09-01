#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Fix autotools timestamps to prevent configure regeneration
# (autoconf is not installed in this container)
cd ${SRC:-/src}/imagemagick
find . -name "*.am" -exec touch {} + 2>/dev/null || true
find . -name "*.in" -exec touch {} + 2>/dev/null || true
sleep 1
find . -name "configure*" -maxdepth 1 -exec touch {} + 2>/dev/null || true
touch version.sh gitversion.sh 2>/dev/null || true
sleep 1
touch configure 2>/dev/null || true

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
# apt deletes a .deb from the cache right after installing it
# (APT::Keep-Downloaded-Packages defaults to false), which breaks a SECOND
# --no-download install in the same script. Keep them.
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
apt-get install -y --download-only pkg-config
# Stage the .debs outside apt's cache: apt removes them as it installs, so a
# second --no-download install in the same script would find an empty cache.
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true
