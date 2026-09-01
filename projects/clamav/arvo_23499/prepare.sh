#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install build dependencies needed by compile.sh and test.sh
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq zlib1g-dev libcurl4-openssl-dev > /dev/null 2>&1

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
# apt deletes a .deb from the cache right after installing it
# (APT::Keep-Downloaded-Packages defaults to false), which breaks a SECOND
# --no-download install in the same script. Keep them.
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
apt-get install -y --download-only check libbz2-dev libcurl4-openssl-dev libncurses5-dev libsubunit-dev libxml2-dev pkg-config zlib1g-dev
# Stage the .debs outside apt's cache: apt removes them as it installs, so a
# second --no-download install in the same script would find an empty cache.
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true
