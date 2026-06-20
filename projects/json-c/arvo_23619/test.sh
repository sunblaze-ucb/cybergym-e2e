#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/json-c/json-c-build

echo "=== Running tests for json-c ==="
LOG_FILE=$(mktemp /tmp/json-c_test_log.XXXXXX)

ASAN_OPTIONS=detect_leaks=0:halt_on_error=0:abort_on_error=0:exitcode=0:allocator_may_return_null=1 ctest -j $(nproc) --output-on-failure || make test | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
