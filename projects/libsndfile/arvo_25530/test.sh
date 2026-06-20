#!/bin/bash
set -uo pipefail

cd "$SRC/libsndfile"

if make check -j$(nproc) CFLAGS="-w" CXXFLAGS="-w"; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi

