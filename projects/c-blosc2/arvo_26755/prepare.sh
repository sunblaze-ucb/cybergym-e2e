#!/usr/bin/env bash

# Prepare.sh for c-blosc2 arvo_26755
# Install LLVM/Clang 14 because clang 22's MSan doesn't detect the
# use-of-uninitialized-value bug in Lizard_decompress_LIZv1.
# Clang 14 properly catches this MSan issue.

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
