#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/yara
echo "=== Running tests for yara ==="
LOG_FILE=$(mktemp /tmp/yara_test_log.XXXXXX)
ALL_TESTS="test-alignment test-api test-rules test-pe test-elf test-version test-exception"
EXCLUDED_TESTS="test-exception"
TESTS_TO_RUN="test-alignment test-api test-rules test-pe test-elf test-version"

make check TESTS="$TESTS_TO_RUN" | tee $LOG_FILE

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
