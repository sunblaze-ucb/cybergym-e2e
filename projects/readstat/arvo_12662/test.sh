#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/readstat

echo "=== Running tests for readstat ==="
LOG_FILE=$(mktemp /tmp/readstat_test_log.XXXXXX)

# Re-build test without MSAN
make clean && make -j$(nproc)

# Run tests
make -j$(nproc) check 2>&1 | tee $LOG_FILE || true

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ Build and tests completed"
    exit 0
else
    echo "✗ Build or tests failed"
    exit 1
fi
