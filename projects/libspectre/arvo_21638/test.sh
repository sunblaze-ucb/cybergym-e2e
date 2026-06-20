#!/bin/bash
# test.sh - ALL unit tests for libspectre (arvo_21638)
#
# This script runs the COMPLETE test suite for the libspectre project.
# libspectre has 3 test programs (spectre-test, parser-test, fuzz-test)
# that are exercised against all available PS/EPS test files from
# the bundled ghostscript-9.50 examples directory.
#
# Test programs:
#   - parser-test: Tests PostScript document parsing (ps.c)
#   - fuzz-test: Tests the spectre_read_fuzzer (document load from stream)
#   - spectre-test: Tests rendering, export, metadata, and page operations
#
# Excluded tests: None - all tests pass
#
# Total test invocations: 37 (make check + 3 programs x 12 test files)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/libspectre

# Install required dependencies if not present
if ! command -v pkg-config &>/dev/null || ! pkg-config --exists cairo 2>/dev/null; then
    apt-get update -qq
    apt-get install -y -qq pkg-config libcairo2-dev libgs-dev ghostscript autoconf automake libtool 2>&1 | tail -5
fi

# Build the project with tests enabled if not already built
if [ ! -f test/parser-test ] || [ ! -f test/fuzz-test ] || [ ! -f test/spectre-test ]; then
    # Clean any previous sanitizer-instrumented build
    make distclean 2>/dev/null || true
    ./autogen.sh --enable-test 2>&1 | tail -5
    make -j$(nproc) 2>&1 | tail -5
fi

# Collect all PS/EPS test files from ghostscript examples
PS_FILES=$(find /src/libspectre/ghostscript-9.50/examples -maxdepth 1 \( -name "*.ps" -o -name "*.eps" \) | sort)

TOTAL=0
PASSED=0

# Run make check (build system's own check target)
echo "=== Running make check ==="
make check 2>&1
echo "make check: PASSED"
TOTAL=$((TOTAL+1))
PASSED=$((PASSED+1))

# Run parser-test with all PS/EPS files
echo ""
echo "=== Running parser-test ==="
for f in $PS_FILES; do
    fname=$(basename "$f")
    outdir=$(mktemp -d /tmp/parser_test_XXXXXX)
    LD_LIBRARY_PATH=/src/libspectre/libspectre/.libs timeout 30 ./test/parser-test "$f" "$outdir" 2>&1
    echo "PASS: parser-test $fname"
    TOTAL=$((TOTAL+1))
    PASSED=$((PASSED+1))
    rm -rf "$outdir"
done

# Run fuzz-test with all PS/EPS files
echo ""
echo "=== Running fuzz-test ==="
for f in $PS_FILES; do
    fname=$(basename "$f")
    LD_LIBRARY_PATH=/src/libspectre/libspectre/.libs timeout 30 ./test/fuzz-test "$f" 2>&1
    echo "PASS: fuzz-test $fname"
    TOTAL=$((TOTAL+1))
    PASSED=$((PASSED+1))
done

# Run spectre-test with all PS/EPS files
echo ""
echo "=== Running spectre-test ==="
for f in $PS_FILES; do
    fname=$(basename "$f")
    outdir=$(mktemp -d /tmp/spectre_test_XXXXXX)
    LD_LIBRARY_PATH=/src/libspectre/libspectre/.libs timeout 60 ./test/spectre-test "$f" "$outdir" 2>&1
    echo "PASS: spectre-test $fname"
    TOTAL=$((TOTAL+1))
    PASSED=$((PASSED+1))
    rm -rf "$outdir"
done

echo ""
echo "=== Summary ==="
echo "Total: $TOTAL, Passed: $PASSED, Failed: 0"
echo "All tests passed!"
exit 0
