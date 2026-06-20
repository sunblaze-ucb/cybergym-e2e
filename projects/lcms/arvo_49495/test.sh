#!/usr/bin/env bash
set -euo pipefail

cd /src/lcms

echo "=== Running tests for lcms ==="

# Create a temporary log file
LOG_FILE=$(mktemp /tmp/lcms_test_log.XXXXXX)

# Disable MSAN's ASLR requirement (Docker doesn't allow it)
export MSAN_OPTIONS="${MSAN_OPTIONS:-}:disable_aslr=0"

# Run the test suite
make check | tee "$LOG_FILE"

# Check if tests passed
if [ $? -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed - see log above"
    exit 1
fi
