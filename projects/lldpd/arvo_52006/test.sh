#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/lldpd

echo "=== Running tests for lldpd ==="
LOG_FILE=$(mktemp /tmp/lldpd_test_log.XXXXXX)

make check -j$(nproc) | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
