#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/skcms

# Derive san flags from the environment, falling back to ASan+UBSan as a common case
SAN_FLAGS="-fsanitize=address,undefined"
# If your CFLAGS has -fsanitize=fuzzer, replace it with -fsanitize=fuzzer-no-link
CFLAGS_NO_FUZZ="${CFLAGS/-fsanitize=fuzzer/-fsanitize=fuzzer-no-link}"

$CC $CFLAGS_NO_FUZZ $SAN_FLAGS -I. tests.c skcms.o -o tests -lm

echo "=== Running tests for skcms ==="

cmake .

if command -v ctest &> /dev/null; then
    ctest --output-on-failure
    exit $?
else
    echo "✗ CTest not found"
    exit 1
fi
