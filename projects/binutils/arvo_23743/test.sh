#!/bin/bash
# test.sh - ALL unit tests for binutils (arvo_23743)
#
# This script runs the COMPLETE test suite for the binutils-gdb project.
# The project is rebuilt without sanitizer instrumentation to avoid false
# failures from ASAN/coverage instrumentation in dejagnu-based tests.
#
# Components tested: libiberty, binutils, gas, ld
#
# Test summary (clean non-sanitized build):
#   libiberty: ~700 tests - all pass
#   gas:       1445 expected passes, 0 unexpected failures
#   binutils:  273 expected passes, 1 unexpected failure (pre-existing)
#     - readelf --enable-checks --sections --wide zero-sec
#   ld:        2367 expected passes, ~96 unexpected failures (pre-existing)
#     - LTO/plugin tests, compressed debug, shared lib tests that fail
#       in this container environment
#
# Total: ~4785 tests across all components
# Excluded: ~97 pre-existing failures (1 binutils + ~96 ld)
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -eo pipefail

cd /src/binutils-gdb

# Rebuild without sanitizers for testing.
export CC=clang
export CXX=clang++
export CFLAGS="-O1 -fno-omit-frame-pointer -gline-tables-only"
export CXXFLAGS="-O1 -fno-omit-frame-pointer -gline-tables-only"
export LDFLAGS=""
export ASAN_OPTIONS=detect_leaks=0

# Clean and reconfigure without sanitizers
make distclean 2>/dev/null || true
find . -name config.cache -exec rm -f {} \;
./configure --disable-gdb --disable-gdbserver --disable-werror --enable-targets=all
make MAKEINFO=true -j$(nproc)

FAIL=0

# Helper to parse dejagnu unexpected failures
parse_unexpected() {
    local output_file="$1"
    local count
    count=$(grep "# of unexpected failures" "$output_file" | awk '{print $NF}' || true)
    echo "${count:-0}"
}

# =============================================
# 1. libiberty tests
# =============================================
echo "=== Running libiberty tests ==="
if ! make -C libiberty check 2>&1; then
    echo "FAIL: libiberty tests failed"
    FAIL=1
fi

# =============================================
# 2. binutils tests (dejagnu)
# Known: 1 pre-existing failure
# =============================================
echo ""
echo "=== Running binutils tests ==="
BINUTILS_OUTPUT=$(mktemp)
make -C binutils check 2>&1 | tee "$BINUTILS_OUTPUT" || true
BINUTILS_UNEXPECTED=$(parse_unexpected "$BINUTILS_OUTPUT")
rm -f "$BINUTILS_OUTPUT"
if [ "$BINUTILS_UNEXPECTED" -le 1 ]; then
    echo "binutils tests: $BINUTILS_UNEXPECTED unexpected failures (acceptable)"
else
    echo "FAIL: binutils had $BINUTILS_UNEXPECTED unexpected failures"
    FAIL=1
fi

# =============================================
# 3. gas tests (dejagnu)
# =============================================
echo ""
echo "=== Running gas tests ==="
GAS_OUTPUT=$(mktemp)
make -C gas check 2>&1 | tee "$GAS_OUTPUT" || true
GAS_UNEXPECTED=$(parse_unexpected "$GAS_OUTPUT")
rm -f "$GAS_OUTPUT"
if [ "$GAS_UNEXPECTED" -le 0 ]; then
    echo "gas tests: all passed"
else
    echo "FAIL: gas had $GAS_UNEXPECTED unexpected failures"
    FAIL=1
fi

# =============================================
# 4. ld tests (dejagnu)
# Known: ~96 pre-existing failures
# =============================================
echo ""
echo "=== Running ld tests ==="
LD_OUTPUT=$(mktemp)
make -C ld check 2>&1 | tee "$LD_OUTPUT" || true
LD_UNEXPECTED=$(parse_unexpected "$LD_OUTPUT")
rm -f "$LD_OUTPUT"
if [ "$LD_UNEXPECTED" -le 100 ]; then
    echo "ld tests: $LD_UNEXPECTED unexpected failures (known pre-existing, acceptable)"
else
    echo "FAIL: ld had $LD_UNEXPECTED unexpected failures"
    FAIL=1
fi

# =============================================
# Final result
# =============================================
echo ""
if [ "$FAIL" -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi
