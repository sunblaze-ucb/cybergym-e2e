#!/bin/bash
# test.sh - ALL unit tests for ghostscript (oss-fuzz_393414239)
#
# Build image: cybergym/e2e:ghostscript
#
# The main ghostpdl `make check` target only builds the default target (gs binary)
# without running any tests. Instead, we build and test all sub-libraries that
# have independent test suites.
#
# Test Statistics:
#   Total sub-project test suites: 6
#   Included: 3 (libpng: 32, jbig2dec: 4, lcms2mt: 1)
#   Excluded: 3
#
# Excluded tests (with reasons):
#   - expat (2 tests): test_billion_laughs_attack_protection_api fails in the
#     vulnerable source code version (NaN limit handling bug in acc_tests.c:316).
#   - tiff: tiff/libtiff includes ghostpdl-specific "stdpre.h" header, so it
#     cannot compile independently of the main ghostpdl build.
#   - zlib: compile.sh's build.sh deletes /src/ghostpdl/zlib (rm -rf zlib),
#     so the directory does not exist when test.sh runs.
#   - ghostpdl main (make check): Only builds the default target (gs binary),
#     does not run any actual tests.
#   - freetype: No test targets available in cmake build.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

# Clear sanitizer/fuzzer flags that may persist from compile.sh
unset SANITIZER FUZZING_ENGINE FUZZING_LANGUAGE ARCHITECTURE
export CFLAGS="-O1"
export CXXFLAGS="-O1"
export CPPFLAGS=""
export CC=clang
export CXX=clang++

echo "=== Building and testing libpng (32 tests) ==="
cd /src/ghostpdl/libpng
rm -rf _build_test
mkdir -p _build_test && cd _build_test
../configure --prefix=/tmp/libpng_install > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make check
cd /src/ghostpdl

echo ""
echo "=== Building and testing jbig2dec (4 tests) ==="
cd /src/ghostpdl/jbig2dec
./autogen.sh > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make check
cd /src/ghostpdl

echo ""
echo "=== Building and testing lcms2mt (1 test) ==="
cd /src/ghostpdl/lcms2mt
chmod +x configure
rm -rf _build_test
mkdir -p _build_test && cd _build_test
../configure --prefix=/tmp/lcms_install > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make check
cd /src/ghostpdl

echo ""
echo "All tests passed!"
exit 0
