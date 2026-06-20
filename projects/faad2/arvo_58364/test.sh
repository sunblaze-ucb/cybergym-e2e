#!/usr/bin/env bash

cd ${SRC:-/src}/faad2

echo "=== Running tests for faad2 ==="
LOG_FILE=$(mktemp /tmp/faad2_test_log.XXXXXX)

make check | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
