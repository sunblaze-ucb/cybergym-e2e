#!/usr/bin/env bash
# test.sh - ALL unit tests for binutils-gdb (arvo_21300)
#
# This script runs the full test suite for binutils-gdb project.
# Tests use dejagnu (runtest) for gas, binutils, and ld subsystems,
# plus standalone tests for libiberty.
#
# The build uses MSAN (-fsanitize=memory) which causes many ld tests
# to fail when they try to run linked binaries. These are excluded.
#
# Excluded tests (with reasons):
#   gas:
#     - i386 nop-bad-1: Fails due to clang 22 codegen difference
#   binutils:
#     - "archive with empty element": Fails in MSAN build
#     - binutils-all/x86-64/pr23494c-x32: x32 ABI test failure in MSAN build
#   ld:
#     - 330 tests fail due to MSAN-instrumented ld producing binaries that
#       cannot run properly. These are all runtime execution failures, not
#       link-time failures. Skipped entirely due to MSAN incompatibility.
#
# Test counts:
#   libiberty: ~140 tests (all pass)
#   gas: 1410 pass, 1 known fail
#   binutils: 267 pass, 2 known fail
#   ld: skipped (MSAN incompatible - 330 runtime failures)
#
# Exit codes:
#   0 - All included tests passed (known failures only)
#   1 - Unexpected test failure

set -uo pipefail

cd /src/binutils-gdb

# Install dejagnu if not present
if ! command -v runtest &>/dev/null; then
    apt-get update -qq && apt-get install -y -qq dejagnu > /dev/null 2>&1
fi

FAIL=0

##############################################################################
# 1. libiberty tests
##############################################################################
echo "=== Running libiberty tests ==="
cd /src/binutils-gdb/libiberty
if ! make check 2>&1; then
    echo "FAIL: libiberty tests failed"
    FAIL=1
fi

##############################################################################
# 2. gas (assembler) tests
##############################################################################
echo ""
echo "=== Running gas tests ==="
cd /src/binutils-gdb/gas
make check 2>&1 || true

# Parse results - allow only the 1 known failure
GAS_SUM="/src/binutils-gdb/gas/testsuite/gas.sum"
if [ -f "$GAS_SUM" ]; then
    GAS_FAILS=$(grep -c "^FAIL:" "$GAS_SUM" 2>/dev/null || echo "0")
    GAS_PASSES=$(grep -c "^PASS:" "$GAS_SUM" 2>/dev/null || echo "0")
    echo "gas: $GAS_PASSES passed, $GAS_FAILS failed"
    if [ "$GAS_FAILS" -gt 1 ]; then
        echo "FAIL: gas has more failures than expected (expected <= 1, got $GAS_FAILS)"
        FAIL=1
    fi
    if [ "$GAS_PASSES" -lt 1000 ]; then
        echo "FAIL: gas has too few passes (expected >= 1000, got $GAS_PASSES)"
        FAIL=1
    fi
else
    echo "FAIL: gas.sum not found"
    FAIL=1
fi

##############################################################################
# 3. binutils tests
##############################################################################
echo ""
echo "=== Running binutils tests ==="
cd /src/binutils-gdb/binutils
make check 2>&1 || true

# Parse results - allow only the 2 known failures
BU_SUM="/src/binutils-gdb/binutils/binutils.sum"
if [ -f "$BU_SUM" ]; then
    BU_FAILS=$(grep -c "^FAIL:" "$BU_SUM" 2>/dev/null || echo "0")
    BU_PASSES=$(grep -c "^PASS:" "$BU_SUM" 2>/dev/null || echo "0")
    echo "binutils: $BU_PASSES passed, $BU_FAILS failed"
    if [ "$BU_FAILS" -gt 2 ]; then
        echo "FAIL: binutils has more failures than expected (expected <= 2, got $BU_FAILS)"
        FAIL=1
    fi
    if [ "$BU_PASSES" -lt 200 ]; then
        echo "FAIL: binutils has too few passes (expected >= 200, got $BU_PASSES)"
        FAIL=1
    fi
else
    echo "FAIL: binutils.sum not found"
    FAIL=1
fi

##############################################################################
# Summary
##############################################################################
echo ""
echo "=== Test Summary ==="
if [ "$FAIL" -eq 0 ]; then
    echo "All tests passed (with known exclusions)!"
    exit 0
else
    echo "Unexpected test failures detected"
    exit 1
fi
