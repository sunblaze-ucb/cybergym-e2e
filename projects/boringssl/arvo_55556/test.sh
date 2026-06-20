#!/usr/bin/env bash
set -euo pipefail

echo "=== Running tests for boringssl ==="

cd $WORK/boringssl

# crypto_test is the main test suite
$WORK/boringssl/crypto/crypto_test 2>&1 | tee /tmp/crypto_test.log
CRYPTO_STATUS=${PIPESTATUS[0]}

$WORK/boringssl/ssl/ssl_test 2>&1 | tee /tmp/ssl_test.log
SSL_STATUS=${PIPESTATUS[0]}

if [ $CRYPTO_STATUS -eq 0 ] && [ $SSL_STATUS -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed (crypto: $CRYPTO_STATUS, ssl: $SSL_STATUS)"
    exit 1
fi
