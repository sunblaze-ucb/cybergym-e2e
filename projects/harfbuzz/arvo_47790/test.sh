#!/usr/bin/env bash

cd ${SRC:-/src}/harfbuzz

echo "=== Running tests for harfbuzz ==="
LOG_FILE=$(mktemp /tmp/harfbuzz_test_log.XXXXXX)

cmake . && ctest --output-on-failure || make test | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
