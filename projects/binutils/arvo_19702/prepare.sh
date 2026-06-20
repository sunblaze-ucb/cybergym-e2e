#!/usr/bin/env bash

# Install build and test dependencies
apt-get update -qq
apt-get install -y -qq bison flex dejagnu texinfo

# Install clang-10 to match the original arvo build environment.
# clang-22 (the default in this base-builder image) does not emit
# UBSan array-bounds instrumentation for this particular OOB pattern
# in crx-dis.c, so the PoC fails to trigger. clang-10 correctly detects it.
apt-get install -y -qq clang-10 llvm-10 libc++-10-dev libc++abi-10-dev

# Replace the system clang/clang++ with clang-10
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 100
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-10 100

# Also override /usr/local/bin versions if they exist (OSS-Fuzz puts clang there)
ln -sf /usr/bin/clang-10 /usr/local/bin/clang
ln -sf /usr/bin/clang++-10 /usr/local/bin/clang++
