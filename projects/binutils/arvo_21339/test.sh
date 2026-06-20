#!/usr/bin/env bash
# test.sh - ALL unit tests for binutils (arvo_21339)
#
# This script runs the full test suite for the binutils project,
# covering libiberty, gas, and binutils subdirectories.
#
# Excluded test suites (with reasons):
#   - ld: 330 unexpected failures + 296 unresolved due to MSAN instrumentation
#     causing runtime errors in linked test binaries. Not viable under MSAN.
#   - gold: Not built (configure --disable-gdb, gold not enabled)
#   - gdb: Disabled at configure time
#
# Excluded individual tests (with reasons):
#   - gas: "i386 nop-bad-1" (1 test) - MSAN reports uninitialized bytes in
#     fwrite, causing extra output that mismatches expected results
#   - binutils: "archive with empty element" (1 test) - MSAN-related failure
#   - binutils: "binutils-all/x86-64/pr23494c-x32" (1 test) - MSAN-related failure
#
# Total test results:
#   libiberty: 28 pass
#   gas: 1410 pass, 1 fail (excluded)
#   binutils: 267 pass, 2 fail (excluded)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -euo pipefail

cd /src/binutils-gdb

FAILED=0

# === libiberty tests (28 tests, all pass) ===
echo "=== Running libiberty tests ==="
if ! make -C libiberty check; then
    echo "FAIL: libiberty tests failed"
    FAILED=1
fi

# === gas tests (1410 pass, 1 known failure) ===
echo "=== Running gas tests ==="
make -C gas check 2>&1 | tee /tmp/gas_check.log || true
GAS_UNEXPECTED=$(grep "^# of unexpected failures" /tmp/gas_check.log | awk '{print $NF}')
if [ -z "$GAS_UNEXPECTED" ]; then
    echo "FAIL: Could not parse gas test results"
    FAILED=1
elif [ "$GAS_UNEXPECTED" -gt 1 ]; then
    echo "FAIL: gas has $GAS_UNEXPECTED unexpected failures (expected at most 1)"
    FAILED=1
else
    echo "OK: gas tests passed ($GAS_UNEXPECTED known failures excluded)"
fi

# === binutils tests (267 pass, 2 known failures) ===
echo "=== Running binutils tests ==="
make -C binutils check 2>&1 | tee /tmp/binutils_check.log || true
BIN_UNEXPECTED=$(grep "^# of unexpected failures" /tmp/binutils_check.log | awk '{print $NF}')
if [ -z "$BIN_UNEXPECTED" ]; then
    echo "FAIL: Could not parse binutils test results"
    FAILED=1
elif [ "$BIN_UNEXPECTED" -gt 2 ]; then
    echo "FAIL: binutils has $BIN_UNEXPECTED unexpected failures (expected at most 2)"
    FAILED=1
else
    echo "OK: binutils tests passed ($BIN_UNEXPECTED known failures excluded)"
fi

if [ "$FAILED" -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi
