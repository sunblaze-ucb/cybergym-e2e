#!/bin/bash
# test.sh - ALL unit tests for mupdf (arvo_5492)
#
# This script runs the COMPLETE test suite for the mupdf project.
# MuPDF has limited standalone test infrastructure. The main unit tests
# are in the thirdparty/extract library.
#
# Tests included:
#   - extract/buffer-test: Buffer handling unit tests
#   - extract/misc-test: Miscellaneous utility tests (XML parsing, etc.)
#   - test-src: Source code style checks (ssize_t, strdup, bzero usage)
#
# Excluded tests (with reasons):
#   - mu-office-test.c: Windows-only test (requires windows.h)
#   - extract/test-exe: Requires mutool/gs binaries not built in container
#   - extract/test-mutool: Requires mutool binary not available
#   - extract/test-gs: Requires ghostscript binary not available
#   - extract/test-html: Requires mutool binary not available
#   - extract/test-tables: Requires mutool binary not available
#   - harfbuzz tests: Require meson build and test infrastructure
#   - freetype tests: Require additional build configuration
#   - lcms2/testbed: Requires configure/make build
#   - jbig2dec/test_jbig2dec.py: Requires built jbig2dec binary
#   - gumbo-parser tests: Require gtest framework
#   - leptonica tests: Require build and test data setup
#
# Total available tests: 3 (extract unit tests)
# Included: 3
# Excluded: 0 from available tests
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

echo "=== Running mupdf unit tests ==="

# Navigate to extract directory
cd /src/mupdf/thirdparty/extract

# Create necessary directories
mkdir -p src/build test/generated

# Build and run buffer tests
echo ""
echo "=== Building and running extract buffer tests ==="
cc -W -Wall -Iinclude -Isrc -g -o src/build/buffer-test.exe \
    src/buffer.c src/buffer-test.c src/outf.c src/alloc.c src/mem.c -lm
./src/build/buffer-test.exe
echo "buffer-test: passed"

# Build and run misc tests
echo ""
echo "=== Building and running extract misc tests ==="
cc -W -Wall -Iinclude -Isrc -g -o src/build/misc-test.exe \
    src/alloc.c src/astring.c src/buffer.c src/mem.c src/misc-test.c src/outf.c src/xml.c -lm
./src/build/misc-test.exe
echo "misc-test: passed"

# Run source code checks
echo ""
echo "=== Running extract source code checks ==="
echo "== Checking for use of ssize_t in source."
if grep -wn ssize_t src/*.c src/*.h include/*.h 2>/dev/null; then
    echo "ERROR: Found ssize_t usage"
    exit 1
fi
echo "ssize_t check: passed"

echo "== Checking for use of strdup in source."
if grep -wn strdup $(ls -d src/*.c src/*.h 2>/dev/null | grep -v src/memento.) 2>/dev/null; then
    echo "ERROR: Found strdup usage"
    exit 1
fi
echo "strdup check: passed"

echo "== Checking for use of bzero in source."
if grep -wn bzero src/*.c src/*.h include/*.h 2>/dev/null; then
    echo "ERROR: Found bzero usage"
    exit 1
fi
echo "bzero check: passed"

echo "test-src: passed"

echo ""
echo "All tests passed!"
exit 0
