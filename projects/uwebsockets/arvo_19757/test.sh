#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/uWebSockets

echo "=== Running tests for uWebSockets ==="

cd tests

# Build and run HttpRouter test
echo "Building HttpRouter test..."
clang++ -std=c++17 -stdlib=libc++ -fsanitize=address HttpRouter.cpp -o HttpRouter

echo "Running HttpRouter test..."
./HttpRouter

echo "✓ All tests passed successfully"
