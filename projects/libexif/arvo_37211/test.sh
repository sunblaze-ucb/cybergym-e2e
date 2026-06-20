#!/usr/bin/env bash
# test.sh - ALL unit tests for libexif (arvo_37211)
#
# This runs the COMPLETE test suite for the libexif project.
# The compile.sh builds the fuzzer targets with ASAN/libfuzzer flags,
# which does not produce the test binaries. This script rebuilds libexif
# with standard compiler settings to run the full autotools test suite.
#
# Test Statistics:
#   Total tests in test/: 13 (12 run + 1 skipped)
#   Total tests in test/nls/: 1
#   Grand total: 14
#   Included: 13 (12 + 1)
#   Skipped: 1 (check-failmalloc.sh - requires libfailmalloc, not installed)
#   Excluded: 0
#
# Tests:
#   test-mem           - Memory allocation tests
#   test-value         - Value handling tests
#   test-integers      - Integer handling tests
#   test-parse         - Parsing tests
#   test-tagtable      - Tag table tests
#   test-sorted        - Sorting tests
#   test-fuzzer        - Fuzzer data tests
#   test-null          - Null handling tests
#   parse-regression.sh - Parse regression script
#   swap-byte-order.sh  - Byte order swap script
#   extract-parse.sh    - Extract and parse script
#   test-gps           - GPS data tests
#   check-failmalloc.sh - Failmalloc tests (SKIPPED - libfailmalloc not available)
#   test/nls/check-localedir.sh - Locale directory check
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/libexif

echo "=== Installing build dependencies for test suite ==="
apt-get update -qq
apt-get install -y -qq autoconf automake libtool gettext autopoint pkg-config gcc g++ make 2>/dev/null || true

echo "=== Rebuilding libexif for test suite (without fuzzer/sanitizer flags) ==="
# Clean any previous build artifacts from the fuzzer build
make distclean 2>/dev/null || make clean 2>/dev/null || true

# Rebuild with standard compiler for tests
export CC=gcc
export CXX=g++
# Clear the fuzzer/sanitizer CFLAGS that were set by compile.sh
unset CFLAGS CXXFLAGS SANITIZER_FLAGS COVERAGE_FLAGS

autoreconf -fiv
./configure --disable-docs
make -j$(nproc)

echo "=== Running full test suite with make check ==="
make check

echo "All tests passed!"
exit 0
