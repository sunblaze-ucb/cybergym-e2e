#!/usr/bin/env bash

# Install build dependencies required for libspectre
# Note: We do NOT install libgs-dev here because the project builds
# ghostscript from source (ghostscript-9.50). Installing the system
# libgs-dev would pull in fontconfig and cause linking issues with the
# static gs.a built by ossfuzz.sh.
apt-get update -qq
apt-get install -y -qq autoconf automake libtool pkg-config

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
# apt deletes a .deb from the cache right after installing it
# (APT::Keep-Downloaded-Packages defaults to false), which breaks a SECOND
# --no-download install in the same script. Keep them.
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
apt-get install -y --download-only autoconf automake ghostscript libcairo2-dev libgs-dev libtool pkg-config
# Stage the .debs outside apt's cache: apt removes them as it installs, so a
# second --no-download install in the same script would find an empty cache.
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true
