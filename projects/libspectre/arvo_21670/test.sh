#!/usr/bin/env bash
# test.sh - ALL unit tests for libspectre (arvo_21670)
#
# This script runs the COMPLETE test suite for the libspectre project.
# libspectre has three test programs: parser-test, fuzz-test, and spectre-test.
#
# Included tests:
#   - parser-test: Tests the PostScript document parser (psscan) on all
#     available PS files from the bundled ghostscript distribution
#   - fuzz-test: Runs the fuzz test harness (without libFuzzer) on all
#     available PS files, exercising spectre_read_fuzzer
#
# Excluded tests (with reasons):
#   - spectre-test: Requires cairo library which is not available in the
#     build container. This test does rendering/export of PS documents and
#     needs cairo for image surface creation.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/libspectre

echo "=== Building test programs ==="

# Build parser-test from source with proper config.h
$CC $CFLAGS -DHAVE_CONFIG_H -I. -Ilibspectre \
    test/parser-test.c libspectre/ps.c libspectre/spectre-utils.c \
    -o /tmp/parser-test 2>/dev/null
echo "Built parser-test"

# Build fuzz-test via make (links against pre-built libspectre)
make -C test fuzz-test > /dev/null 2>&1
echo "Built fuzz-test"

# Collect all PS test files from the ghostscript distribution
PS_FILES=$(find ${SRC:-/src}/libspectre/ghostscript-9.50/lib -name "*.ps" -type f)
PS_COUNT=$(echo "$PS_FILES" | wc -l)
echo "Found $PS_COUNT PostScript test files"

# ==========================================================
# Test 1: parser-test - PS document structure parser
# ==========================================================
echo ""
echo "=== Running parser-test on $PS_COUNT PS files ==="
PASS=0
FAIL=0
mkdir -p /tmp/parser_output

for psfile in $PS_FILES; do
    rm -rf /tmp/parser_output/*
    if timeout 30 /tmp/parser-test "$psfile" /tmp/parser_output > /dev/null 2>&1; then
        PASS=$((PASS+1))
    else
        FAIL=$((FAIL+1))
        echo "FAIL: parser-test on $(basename $psfile)"
    fi
done

echo "parser-test: $PASS passed, $FAIL failed out of $PS_COUNT"

if [ $FAIL -ne 0 ]; then
    echo "parser-test FAILED"
    exit 1
fi

# ==========================================================
# Test 2: fuzz-test - fuzz harness test
# ==========================================================
echo ""
echo "=== Running fuzz-test on $PS_COUNT PS files ==="
PASS=0
FAIL=0

for psfile in $PS_FILES; do
    if timeout 30 test/fuzz-test "$psfile" > /dev/null 2>&1; then
        PASS=$((PASS+1))
    else
        FAIL=$((FAIL+1))
        echo "FAIL: fuzz-test on $(basename $psfile)"
    fi
done

echo "fuzz-test: $PASS passed, $FAIL failed out of $PS_COUNT"

if [ $FAIL -ne 0 ]; then
    echo "fuzz-test FAILED"
    exit 1
fi

echo ""
echo "All tests passed!"
exit 0
