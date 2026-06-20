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
