#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/libical

echo "=== Running tests for libical ==="
LOG_FILE=$(mktemp /tmp/libical_test_log.XXXXXX)

cmake -j $(nproc) . && ctest -j $(nproc) --output-on-failure || make test -j$(nproc) | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
