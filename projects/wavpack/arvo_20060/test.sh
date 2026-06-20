#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/wavpack

echo "=== Running tests for wavpack ==="
LOG_FILE=$(mktemp /tmp/wavpack_test_log.XXXXXX)

# Turn on testing and make the remaining test files
cmake -DBUILD_TESTING=ON .
make -j$(nproc)

# Run tests
ctest -j $(nproc) --output-on-failure | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
