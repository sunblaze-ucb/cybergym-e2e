#!/bin/bash
# test.sh - ALL unit tests for libspectre (arvo_21302)
#
# This script rebuilds ghostscript and libspectre with clean (non-sanitizer) flags
# to enable running the test programs, then runs all three test programs
# (parser-test, spectre-test, fuzz-test) against all available PostScript/EPS files.
#
# The rebuild is necessary because compile.sh builds with MSan sanitizer flags,
# which makes the resulting libraries unusable for the test programs.
#
# Test programs:
#   - parser-test: Tests PostScript document parsing (ps.c)
#   - spectre-test: Tests document loading, metadata, rendering, export, and save
#   - fuzz-test: Tests the fuzzer harness (spectre_read_fuzzer.c) with PS input
#
# Test input files: 12 PS/EPS files from ghostscript-9.50/examples/
#
# Total tests: 36 (3 test programs x 12 input files)
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Clear sanitizer-related environment variables set by compile.sh
unset SANITIZER
export CC=gcc
export CXX=g++
export CFLAGS=""
export CXXFLAGS=""
export LDFLAGS="-L/usr/local/lib -Wl,-rpath,/usr/local/lib"
export LD_LIBRARY_PATH=/usr/local/lib

cd /src/libspectre

# Step 1: Install test dependency (cairo)
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq libcairo2-dev > /dev/null 2>&1

# Step 2: Rebuild ghostscript shared library with clean (non-sanitizer) flags
cd ghostscript-9.50
make clean > /dev/null 2>&1 || true
make distclean > /dev/null 2>&1 || true
./configure > /dev/null 2>&1
make -j$(nproc) so > /dev/null 2>&1
cp sobin/libgs.so.9.50 /usr/local/lib/
ln -sf libgs.so.9.50 /usr/local/lib/libgs.so.9
ln -sf libgs.so.9.50 /usr/local/lib/libgs.so
ldconfig
cd ..

# Step 3: Reconfigure and build libspectre with tests enabled
make distclean > /dev/null 2>&1 || true
./autogen.sh --enable-test > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1

# Step 4: Run all tests
FAILED=0
PASSED=0

PS_FILES=$(find /src/libspectre/ghostscript-9.50/examples -maxdepth 1 \( -name "*.ps" -o -name "*.eps" \) | sort)

# Run parser-test against all PS/EPS files
echo "=== Running parser-test ==="
for f in $PS_FILES; do
    fname=$(basename "$f")
    mkdir -p "/tmp/parser_out/$fname"
    if ./test/parser-test "$f" "/tmp/parser_out/$fname" > /dev/null 2>&1; then
        echo "  PASS: parser-test $fname"
        PASSED=$((PASSED + 1))
    else
        echo "  FAIL: parser-test $fname"
        FAILED=$((FAILED + 1))
    fi
done

# Run spectre-test against all PS/EPS files
echo "=== Running spectre-test ==="
for f in $PS_FILES; do
    fname=$(basename "$f")
    mkdir -p "/tmp/spectre_out/$fname"
    if timeout 60 ./test/spectre-test "$f" "/tmp/spectre_out/$fname" > /dev/null 2>&1; then
        echo "  PASS: spectre-test $fname"
        PASSED=$((PASSED + 1))
    else
        echo "  FAIL: spectre-test $fname"
        FAILED=$((FAILED + 1))
    fi
done

# Run fuzz-test against all PS/EPS files
echo "=== Running fuzz-test ==="
for f in $PS_FILES; do
    fname=$(basename "$f")
    if timeout 60 ./test/fuzz-test "$f" > /dev/null 2>&1; then
        echo "  PASS: fuzz-test $fname"
        PASSED=$((PASSED + 1))
    else
        echo "  FAIL: fuzz-test $fname"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "Results: $PASSED passed, $FAILED failed"

if [ "$FAILED" -gt 0 ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0
