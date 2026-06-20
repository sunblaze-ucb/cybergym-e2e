#!/bin/bash
# test.sh - ALL unit tests for ghostscript (oss-fuzz_414383025)
#
# Build image: cybergym/e2e:ghostscript
#
# This script runs the complete test suites for ghostscript's sub-libraries.
# The main ghostpdl project uses autotools but only builds libgs (no gs binary),
# and its "make check" target just rebuilds the default target without running
# any actual tests. We test the sub-libraries individually.
#
# Test Suites:
#   1. lcms2mt (autotools/make check): ~145 individual checks via testcms2
#      Covers: base types, interpolation, color transforms, profiles,
#      formatters, named colors, CGATS parsing, MD5, plugins, threading
#   2. expat (cmake/ctest): 2 tests (runtests, runtests_cxx)
#      Covers: XML parsing, basic tests, allocation tests, namespace tests
#
# Test Statistics:
#   Total suites: 2 | Total tests/checks: ~147
#   Included: ~147 | Excluded: 0
#
# Excluded sub-libraries (with reasons):
#   - zlib: Source directory removed by build.sh during compile step (rm -rf zlib)
#   - freetype: Source directory removed/replaced by build.sh during compile step
#   - tiff: Build fails with container's toolchain (compiler errors in tif_dirread.c, tif_predict.c)
#   - libpng: CMake build produces no ctest tests; pngtest requires manual setup
#   - jbig2dec: Only has configure.ac.in (not configure.ac), cannot autoreconf
#   - openjpeg: No test suite infrastructure in the bundled copy
#   - ijs: "make check" is a no-op (no test targets defined)
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

# Reset compiler flags to avoid ASan/fuzzer flags from compile.sh
export CC=clang
export CXX=clang++
export CFLAGS="-O1"
export CXXFLAGS="-O1"
export LDFLAGS=""
unset SANITIZER 2>/dev/null || true
unset FUZZING_ENGINE 2>/dev/null || true
unset ARCHITECTURE 2>/dev/null || true
unset FUZZING_LANGUAGE 2>/dev/null || true

echo "=== Running lcms2mt tests (autotools/make check) ==="
cd /src/ghostpdl/lcms2mt
autoreconf -fi > /dev/null 2>&1
./configure --quiet > /dev/null 2>&1
make -j$(nproc) --quiet > /dev/null 2>&1
cd testbed
make check 2>&1
echo "lcms2mt tests passed!"

echo ""
echo "=== Running expat tests (cmake/ctest) ==="
cd /src/ghostpdl/expat
rm -rf build
mkdir -p build && cd build
cmake .. -DEXPAT_BUILD_TESTS=ON -DEXPAT_BUILD_TOOLS=OFF -DEXPAT_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
ctest --output-on-failure 2>&1
echo "expat tests passed!"

echo ""
echo "All tests passed!"
exit 0
