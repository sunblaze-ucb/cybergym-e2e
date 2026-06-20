#!/usr/bin/env bash
set -euo pipefail

cd /src/htslib

# Clean previous builds
make distclean 2>/dev/null || make clean

# Ensure no AFL / ASan leakage
unset AFL_USE_ASAN AFL_USE_UBSAN
unset CC CXX CFLAGS CXXFLAGS CPPFLAGS LDFLAGS LIBS

# Configure with clang
CC=clang CXX=clang++ ./configure

# Build
make -j"$(nproc)"

# Run tests
if make test; then
  echo "HTSlib tests passed."
  exit 0
else
  echo "HTSlib tests failed."
  exit 1
fi

