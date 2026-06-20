#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/libidn2

echo "=== Running tests for libidn2 ==="

# Run just the main tests directory (excluding fuzz which runs indefinitely)
cd tests
make check

echo "✓ All tests passed successfully"
