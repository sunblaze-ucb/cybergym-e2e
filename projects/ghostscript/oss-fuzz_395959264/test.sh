#!/bin/bash
# test.sh - ALL unit tests for ghostscript (oss-fuzz_395959264)
#
# Build image: cybergym/e2e:ghostscript
#
# Test Statistics:
#   Total discovered: 38+ | Included: 38 | Excluded: 2 (expat)
#
# Sub-library test suites run:
#   - jbig2dec: 4 tests (test_sha1, test_jbig2dec.py, test_huffman, test_arith)
#   - libpng: 32 tests (pngtest, pngstest, pngvalid, pngunknown variants, pngimage)
#   - lcms2mt: 1 test suite (testcms - comprehensive with 100+ sub-checks)
#
# Excluded tests:
#   - expat runtests/runtests_cxx: test_billion_laughs_attack_protection_api
#     fails in the vulnerable source version (NaN limit handling bug in
#     acc_tests.c:316, 12 sub-test failures out of 4392)
#
# Libraries whose tests could NOT be built (excluded entirely):
#   - zlib: Deleted by compile.sh (build.sh does rm -rf zlib)
#   - tiff: Fails to compile standalone (missing ghostscript-specific stdpre.h header)
#   - freetype: Replaced by compile.sh; tests require meson (not installed)
#   - ijs: No 'check' target in build system
#   - cups: Tests require running CUPS daemon
#   - openjpeg: No build system in ghostpdl copy
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

echo "=== Building and running jbig2dec tests ==="
cd /src/ghostpdl/jbig2dec
./autogen.sh > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make check

echo ""
echo "=== Building and running libpng tests ==="
cd /src/ghostpdl/libpng
chmod +x configure
./configure > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make check

echo ""
echo "=== Building and running lcms2mt tests ==="
cd /src/ghostpdl/lcms2mt
chmod +x configure autogen.sh
./configure > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make check

echo ""
echo "All tests passed!"
exit 0
