#!/usr/bin/env bash
set -eu

# Install build dependencies
apt-get update -qq
apt-get install -y -qq autoconf automake libtool pkg-config nasm

# Extract source (includes leptonica + all dependencies + build.sh)
cd $SRC
if [ ! -d "$SRC/leptonica" ]; then
    tar xzf /data/src.tgz
    # The tarball includes build.sh at top level - move it to $SRC
    if [ -f "$SRC/build.sh" ]; then
        chmod +x "$SRC/build.sh"
    fi
fi

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
# apt deletes a .deb from the cache right after installing it
# (APT::Keep-Downloaded-Packages defaults to false), which breaks a SECOND
# --no-download install in the same script. Keep them.
echo 'APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99keep-debs
apt-get install -y --download-only gnuplot-nox
# Stage the .debs outside apt's cache: apt removes them as it installs, so a
# second --no-download install in the same script would find an empty cache.
mkdir -p /deps/debs
cp -f /var/cache/apt/archives/*.deb /deps/debs/ 2>/dev/null || true
