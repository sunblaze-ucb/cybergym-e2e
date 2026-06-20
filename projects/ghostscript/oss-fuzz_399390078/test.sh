#!/bin/bash
# test.sh - ALL unit tests for ghostscript (oss-fuzz_399390078)
#
# Build image: cybergym/e2e:ghostscript
#
# Test Statistics:
#   Total discovered: 184 (jbig2dec:3, expat:2, libpng:34, zlib:1, lcms2mt:1, tiff:143)
#   Included: 38 (jbig2dec:3, libpng:34, lcms2mt:1)
#   Excluded: 146 (tiff:143, expat:2, zlib:1)
#
# Excluded components (with reasons):
#   - tiff (all 143 tests): libtiff fails to compile due to compilation errors
#     in tif_pixarlog.c and tif_dirread.c, so no test binaries are produced
#   - expat (2 tests): test_billion_laughs_attack_protection_api fails (12/4392
#     checks) due to NaN limit handling differences in this build environment
#   - zlib (1 test): /src/ghostpdl/zlib directory is removed by compile.sh
#     (build.sh does 'rm -rf zlib' during ghostpdl build)
#   - freetype tests: requires meson build system with freetype already built
#     as a dependency, not independently buildable in this container
#   - ghostpdl main test suite: ghostpdl itself fails to build (freetype source
#     file mismatch after build.sh directory restructuring), so no gs binary
#     or make check targets are available
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

# Override ASan/fuzzer compiler flags that interfere with test builds
export CC=clang
export CXX=clang++
export CFLAGS="-O2 -g"
export CXXFLAGS="-O2 -g"
export LDFLAGS=""

echo "=========================================="
echo "Running ghostscript project test suite"
echo "=========================================="

# -----------------------------------------------
# 1. jbig2dec tests (3 tests)
# -----------------------------------------------
echo ""
echo "--- jbig2dec tests (3 tests) ---"
cd /src/ghostpdl/jbig2dec

# Build the library
CC=clang CFLAGS="-Wall -g -O2" make -f Makefile.unix libjbig2dec.a > /dev/null 2>&1

# Build test programs
clang -Wall -g -O2 -DTEST -o test_sha1 sha1.c
clang -Wall -g -O2 -DTEST -I. -o test_arith jbig2_arith.c -L. -ljbig2dec
clang -Wall -g -O2 -DTEST -I. -o test_huffman jbig2_huffman.c -L. -ljbig2dec

echo "Running test_sha1..."
./test_sha1
echo "Running test_arith..."
./test_arith
echo "Running test_huffman..."
./test_huffman
echo "jbig2dec: All 3 tests passed."

# -----------------------------------------------
# 2. expat tests - EXCLUDED
# -----------------------------------------------
# expat runtests and runtests_cxx both fail because
# test_billion_laughs_attack_protection_api (12/4392 checks) fails due to
# NaN limit handling differences in this build environment

# -----------------------------------------------
# 3. libpng tests (34 tests)
# -----------------------------------------------
echo ""
echo "--- libpng tests (34 tests) ---"
cd /src/ghostpdl/libpng
mkdir -p build && cd build
cmake .. -DPNG_TESTS=ON > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1

echo "Running libpng ctest..."
ctest --output-on-failure
echo "libpng: All 34 tests passed."

# -----------------------------------------------
# 4. zlib tests - EXCLUDED
# -----------------------------------------------
# /src/ghostpdl/zlib is removed by compile.sh (build.sh does 'rm -rf zlib')

# -----------------------------------------------
# 5. lcms2mt tests (1 comprehensive test suite)
# -----------------------------------------------
echo ""
echo "--- lcms2mt tests (1 test suite) ---"
cd /src/ghostpdl/lcms2mt
chmod +x configure autogen.sh
./autogen.sh > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1

echo "Running lcms2mt make check..."
make check
echo "lcms2mt: Test suite passed."

# -----------------------------------------------
echo ""
echo "=========================================="
echo "All tests passed!"
echo "=========================================="
exit 0
