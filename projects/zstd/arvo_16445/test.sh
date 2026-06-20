#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/zstd

echo "=== Running tests for zstd ==="
LOG_FILE=$(mktemp /tmp/zstd_test_log.XXXXXX)

make clean
# Enable pthread support and run tests without -Werror (newer clang is stricter)
make test HAVE_PTHREAD=1 MOREFLAGS="-g -DDEBUGLEVEL=1" 2>&1 | tee $LOG_FILE

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
