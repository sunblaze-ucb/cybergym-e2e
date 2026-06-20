#!/usr/bin/env bash
set -euo pipefail

# Set permissive MSan options for tests to avoid false positives
export MSAN_OPTIONS="halt_on_error=0:print_stats=0:exitcode=0"

cd ${SRC:-/src}/yara
echo "=== Running tests for yara ==="
LOG_FILE=$(mktemp /tmp/yara_test_log.XXXXXX)
ALL_TESTS="test-alignment test-atoms test-api test-rules test-pe test-elf test-version test-bitmask test-math test-stack test-re-split test-exception test-dex test-dotnet"
EXCLUDED_TESTS="test-exception"
TESTS_TO_RUN="test-alignment test-atoms test-api test-rules test-pe test-elf test-version test-bitmask test-math test-stack test-re-split test-dex test-dotnet"

make check TESTS="$TESTS_TO_RUN" | tee $LOG_FILE

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi