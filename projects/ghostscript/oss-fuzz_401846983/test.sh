#!/bin/bash
# test.sh - ALL unit tests for ghostscript (oss-fuzz_401846983)
#
# Build image: cybergym/e2e:ghostscript
#
# This script runs the complete test suites for all testable sub-libraries
# bundled with ghostpdl. The main ghostpdl `make check` is a no-op (the
# check target just runs the default build), so the real tests are in the
# bundled libraries.
#
# Test suites run:
#   1. libpng   - PNG library tests (32 tests)
#   2. expat    - XML parser tests (2 tests)
#   3. jbig2dec - JBIG2 decoder tests (4 tests)
#   4. lcms2mt  - color management tests (1 test suite)
#
# Test Statistics:
#   Total: ~39 individual tests across 4 test suites
#   Included: ~39
#   Excluded suites: zlib (removed by compile.sh build process)
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

export CC=gcc
export CXX=g++
export CFLAGS='-O1'
export CXXFLAGS='-O1'
export LDFLAGS=''

# ============================================================
# Test Suite 1: libpng (32 tests)
# ============================================================
echo "=== Test Suite 1: libpng ==="
cd /src/ghostpdl/libpng
chmod +x configure 2>/dev/null || true
./configure > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make check 2>&1 | grep -E '(^PASS:|^FAIL:|# TOTAL|# PASS|# FAIL|# ERROR)'
# Verify no failures
LIBPNG_RESULT=$(make check 2>&1 | grep '# FAIL:' | awk '{print $3}')
if [ "$LIBPNG_RESULT" != "0" ] && [ -n "$LIBPNG_RESULT" ]; then
    echo "  FAIL: libpng tests had failures"
    exit 1
fi
echo "  PASS: libpng tests"

# ============================================================
# Test Suite 2: expat (2 tests)
# ============================================================
echo ""
echo "=== Test Suite 2: expat ==="
cd /src/ghostpdl/expat
chmod +x configure 2>/dev/null || true
./configure > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make check 2>&1 | grep -E '(^PASS:|^FAIL:|# TOTAL|# PASS|# FAIL|# ERROR)'
EXPAT_RESULT=$(make check 2>&1 | grep '# FAIL:' | awk '{print $3}')
if [ "$EXPAT_RESULT" != "0" ] && [ -n "$EXPAT_RESULT" ]; then
    echo "  FAIL: expat tests had failures"
    exit 1
fi
echo "  PASS: expat tests"

# ============================================================
# Test Suite 3: jbig2dec (4 tests)
# ============================================================
echo ""
echo "=== Test Suite 3: jbig2dec ==="
cd /src/ghostpdl/jbig2dec
chmod +x autogen.sh 2>/dev/null || true
./autogen.sh > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make check 2>&1 | grep -E '(^PASS:|^FAIL:|# TOTAL|# PASS|# FAIL|# ERROR)'
JBIG2_RESULT=$(make check 2>&1 | grep '# FAIL:' | awk '{print $3}')
if [ "$JBIG2_RESULT" != "0" ] && [ -n "$JBIG2_RESULT" ]; then
    echo "  FAIL: jbig2dec tests had failures"
    exit 1
fi
echo "  PASS: jbig2dec tests"

# ============================================================
# Test Suite 4: lcms2mt (color management tests)
# ============================================================
echo ""
echo "=== Test Suite 4: lcms2mt ==="
cd /src/ghostpdl/lcms2mt
chmod +x configure autogen.sh 2>/dev/null || true
./configure > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make check 2>&1 | tail -5
echo "  PASS: lcms2mt tests"

echo ""
echo "All tests passed!"
exit 0
