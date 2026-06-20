#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/h2o

echo "=== Running unit tests for h2o ==="

rm -rf CMakeCache.txt CMakeFiles
cmake -DBUILD_FUZZER=OFF .

echo "Building unit tests..."
make t-00unit-evloop.t -j$(nproc)

echo "Running unit tests..."
./t-00unit-evloop.t

echo "✓ All tests passed successfully"
