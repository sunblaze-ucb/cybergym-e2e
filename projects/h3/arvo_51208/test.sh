#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/h3

# Recompile tests...
cmake . -DBUILD_FUZZERS=OFF
make -j$(nproc)

if ctest . -j $(nproc) --output-on-failure; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
