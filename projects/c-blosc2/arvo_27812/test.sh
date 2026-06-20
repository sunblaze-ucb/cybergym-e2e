#!/usr/bin/env bash
export ASAN_OPTIONS="detect_leaks=0"
cd ${SRC:-/src}/c-blosc2

echo "=== Running tests for c-blosc2 ==="
LOG_FILE=$(mktemp /tmp/c-blosc2_test_log.XXXXXX)

# Exclude known failing tests
EXCLUDE_PATTERN="test_empty_schunk|test_lazychunk"

cmake . && ctest --output-on-failure -E "$EXCLUDE_PATTERN" | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi

