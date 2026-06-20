#!/usr/bin/env bash

cd ${SRC:-/src}/fribidi

apt-get update
apt-get install -y \
    meson \
    ninja-build \
    pkg-config \
    libglib2.0-dev \
    gtk-doc-tools

rm -rf build

echo "✓ Preparation complete"
