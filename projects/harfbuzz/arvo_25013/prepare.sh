#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install meson (required by build.sh for compiling harfbuzz)
pip3 install meson ninja

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
# apt deletes a .deb from the cache right after installing it
# (APT::Keep-Downloaded-Packages defaults to false), which breaks a SECOND
# --no-download install in the same script. Keep them.
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
apt-get install -y --download-only libfreetype6-dev libglib2.0-dev libicu-dev pkg-config
mkdir -p /deps/wheels
pip3 download -d /deps/wheels meson ninja
# Stage the .debs outside apt's cache: apt removes them as it installs, so a
# second --no-download install in the same script would find an empty cache.
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true
