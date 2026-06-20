#!/usr/bin/env bash
set -euo pipefail

# Project root inside the container
PROJECT_ROOT="${SRC:-/src}/md4c"
BUILD_DIR="$PROJECT_ROOT/build"

cd "$PROJECT_ROOT"

echo "=== Running tests for md4c ==="
LOG_FILE=$(mktemp /tmp/md4c_test_log.XXXXXX)

# Ensure build directory exists and move into it
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure and build with shared libs (needed for upstream test harness)
cmake .. -DBUILD_SHARED_LIBS=ON
make -j"$(nproc)"

echo "=== Running upstream md4c test suite ==="

# Run the upstream test runner from the build directory, log output
set +e
../scripts/run-tests.sh | tee "$LOG_FILE"
status=${PIPESTATUS[0]}
set -e

# Check if tests passed
if [ "$status" -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
