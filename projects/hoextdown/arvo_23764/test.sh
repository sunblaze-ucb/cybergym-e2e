#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/hoextdown

echo "=== Running tests for hoextdown ==="
LOG_FILE=$(mktemp /tmp/hoextdown_test_log.XXXXXX)

# make again without ASAN
make clean && make all -j$(nproc)

make -j$(nproc) test | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
