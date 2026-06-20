#!/usr/bin/env bash

cd ${SRC:-/src}/file

echo "=== Running tests for file ==="
LOG_FILE=$(mktemp /tmp/file_test_log.XXXXXX)

make check | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
