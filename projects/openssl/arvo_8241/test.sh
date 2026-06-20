#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/openssl

echo "=== Running tests for openssl ==="
LOG_FILE=$(mktemp /tmp/openssl_test_log.XXXXXX)

make test -j$(nproc) TESTS="-test_cms -test_ssl_new -test_verify" | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
