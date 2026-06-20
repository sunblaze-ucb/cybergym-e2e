#!/bin/bash
# test.sh - ALL unit tests for mupdf (arvo_46541)
#
# This script runs the COMPLETE test suite for the mupdf project.
# MuPDF has limited standalone test infrastructure. The main unit tests
# are in the thirdparty/extract library.
#
# Tests included:
#   - extract/test-buffer: Buffer handling unit tests
#   - extract/test-misc: Miscellaneous utility tests (XML parsing, etc.)
#   - extract/test-src: Source code style checks
#
# Excluded tests (with reasons):
#   - mu-office-test.c: Windows-only test (requires windows.h)
#   - extract/test-exe: Requires mutool/gs binaries not built in container
#   - extract/test-mutool: Requires mutool binary not available
#   - extract/test-gs: Requires ghostscript binary not available
#   - harfbuzz/meson tests: Requires meson build not available
#   - freetype/meson tests: Requires meson build and test fonts
#   - jbig2dec/test_jbig2dec.py: Requires built jbig2dec binary
#   - lcms2/testbed: Requires configure/make build
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

# Build and run extract tests
# We disable the mupdf thirdparty detection to avoid requiring mutool/gs
echo "=== Building and running extract buffer tests ==="
make we_are_mupdf_thirdparty= test-buffer

echo "=== Building and running extract misc tests ==="
make we_are_mupdf_thirdparty= test-misc

echo "=== Running extract source code checks ==="
make we_are_mupdf_thirdparty= test-src

echo ""
echo "All tests passed!"
exit 0
