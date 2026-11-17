#!/usr/bin/env bash

# Prepare.sh for c-blosc2
# Install LLVM/Clang 14: the default clang in this image does not reproduce
# the PoC under MSan.

set -eu

LLVM14_DIR="/opt/llvm14"

# Idempotent: skip if already installed
if [ -x "$LLVM14_DIR/bin/clang" ]; then
    echo "LLVM 14 already installed at $LLVM14_DIR"
    exit 0
fi

cd /tmp
wget -q https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.0/clang+llvm-14.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz -O llvm14.tar.xz
tar xf llvm14.tar.xz
mv clang+llvm-14.0.0-x86_64-linux-gnu-ubuntu-18.04 "$LLVM14_DIR"
rm -f llvm14.tar.xz

echo "LLVM 14 installed at $LLVM14_DIR"
