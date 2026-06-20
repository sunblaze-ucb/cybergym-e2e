#!/bin/bash
# test.sh - ALL unit tests for ghostscript (oss-fuzz_395969084)
#
# Build image: cybergym/e2e:ghostscript
#
# Runs the complete test suites for all ghostscript sub-projects
# that have unit tests, after compile.sh has run.
#
# Test Statistics:
#   Total: 3 sub-project test suites
#   Included: 3
#   Excluded:
#     - tiff: depends on ghostscript-internal stdpre.h header, can't build standalone
#     - zlib: deleted by compile.sh (build.sh removes it)
#     - gs binary: can't build after compile.sh replaces freetype with incompatible version
#     - expat: build + test exceeds time limit (4392 checks pass when run manually)
#
# Sub-project tests:
#   - jbig2dec: 4 tests (test_sha1, test_jbig2dec.py, test_huffman, test_arith)
#   - lcms2mt: testcms (comprehensive color management checks)
#   - libpng: pngtest (PNG read/write validation)
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

##############################################################################
# jbig2dec tests (4 tests)
##############################################################################
echo "=== jbig2dec tests ==="
cd /src/ghostpdl/jbig2dec
chmod +x autogen.sh
./autogen.sh > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make check
echo "PASS: jbig2dec"

##############################################################################
# lcms2mt test suite
##############################################################################
echo ""
echo "=== lcms2mt tests ==="
cd /src/ghostpdl/lcms2mt
chmod +x configure
./configure > /dev/null 2>&1
make -j$(nproc) check > /dev/null 2>&1
cd testbed && ./testcms > /dev/null 2>&1
echo "PASS: lcms2mt"

##############################################################################
# libpng pngtest
##############################################################################
echo ""
echo "=== libpng pngtest ==="
cd /src/ghostpdl/libpng
chmod +x configure 2>/dev/null
./configure > /dev/null 2>&1
make -j$(nproc) pngtest > /dev/null 2>&1
./pngtest
echo "PASS: libpng"

echo ""
echo "All tests passed!"
exit 0
