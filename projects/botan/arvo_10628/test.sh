#!/usr/bin/env bash

cd ${SRC:-/src}/botan

echo ""
echo "=== Building tests ==="
make -j$(nproc) tests
if [ $? -ne 0 ]; then
    echo "Build failed"
    exit 1
fi

echo ""
echo "=== Running botan test suite ==="
./botan-test
EXIT_CODE=$?

echo ""
echo "========================================="
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "✓ Tests passed"
    echo "========================================="
    exit 0
else
    echo "✗ Tests failed (exit code: $EXIT_CODE)"
    echo "========================================="
    exit 1
fi
