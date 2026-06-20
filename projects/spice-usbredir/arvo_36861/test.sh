#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/spice-usbredir

echo "=== Running tests for spice-usbredir ==="

# Tests need to be run from the build directory
cd /work/build
meson test

echo "✓ All tests passed successfully"
