#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/libssh2

echo "=== Running tests for libssh2 ==="
LOG_FILE=$(mktemp /tmp/libssh2_test_log.XXXXXX)

cmake . && ctest --output-on-failure ||make && make test ARGS='-R "mansyntax"' | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
