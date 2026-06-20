#!/usr/bin/env bash
set -eux

# Install build dependencies
apt-get update
apt-get install -y \
    autoconf \
    automake \
    libtool-bin \
    pkg-config \
    flex \
    bison \
    libglib2.0-dev \
    libgcrypt20-dev

cd $SRC/wireshark

# Clean any previous builds
make clean || true
rm -rf /work/install
rm -rf /work/build
