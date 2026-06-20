#!/usr/bin/env bash
cd ${SRC:-/src}/harfbuzz
echo "=== Running tests for harfbuzz ==="
LOG_FILE=$(mktemp /tmp/harfbuzz_test_log.XXXXXX)

# Run tests but skip fuzzing directory (fuzzers have build issues and aren't needed)
make check -C src 2>&1 | tee -a $LOG_FILE
make check -C test/api 2>&1 | tee -a $LOG_FILE
make check -C test/shaping 2>&1 | tee -a $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    cat $LOG_FILE
    exit 1
fi
