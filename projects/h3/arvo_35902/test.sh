#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/h3/build

echo "=== Running tests for h3 ==="

# Run tests with ctest
if ctest . -j $(nproc) --output-on-failure; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
