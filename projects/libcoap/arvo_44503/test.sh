#!/bin/bash
set -euo pipefail

cd $SRC/libcoap

echo "=== Running unit tests for libcoap ==="
LOG_FILE=$(mktemp /tmp/libcoap_test_log.XXXXXX)

./tests/testdriver | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
