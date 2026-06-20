#!/usr/bin/env bash
set -eux

# Install dependencies
apt-get update
apt-get install -y pkg-config autoconf automake libtool ragel libfreetype6-dev libglib2.0-dev libcairo2-dev

cd $SRC/harfbuzz

# Build harfbuzz
./autogen.sh
./configure --enable-static --disable-shared
make clean
make -j$(nproc)
