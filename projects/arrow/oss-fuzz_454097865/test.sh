#!/bin/bash
# test.sh - ALL unit tests for arrow (oss-fuzz_454097865)
#
# Build image: cybergym/e2e:arrow
#
# This script rebuilds Arrow C++ with tests enabled (the original OSS-Fuzz
# build has -DARROW_BUILD_TESTS=off) and runs the complete test suite.
#
# Test Statistics:
#   Total: 48 | Included: 48 | Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Install Boost headers (needed for build)
cd $SRC/
tar jxf boost_1_85_0.tar.bz2
cd boost_1_85_0/
CFLAGS="" CXXFLAGS="" ./bootstrap.sh > /dev/null 2>&1
CFLAGS="" CXXFLAGS="" ./b2 headers > /dev/null 2>&1
cp -R boost/ /usr/include/

# Configure Arrow C++ with tests enabled
mkdir -p /work/build && cd /work/build

export ASAN_OPTIONS="detect_leaks=0"
export PARQUET_TEST_DATA=/src/arrow/cpp/submodules/parquet-testing/data
export ARROW_TEST_DATA=/src/arrow/testing/data

cmake /src/arrow/cpp -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DARROW_DEPENDENCY_SOURCE=BUNDLED \
    -DBOOST_SOURCE=BUNDLED \
    -DCMAKE_C_FLAGS="-O1 -fno-omit-frame-pointer" \
    -DCMAKE_CXX_FLAGS="-O1 -fno-omit-frame-pointer -stdlib=libc++" \
    -DARROW_EXTRA_ERROR_CONTEXT=off \
    -DARROW_JEMALLOC=off \
    -DARROW_MIMALLOC=off \
    -DARROW_FILESYSTEM=off \
    -DARROW_PARQUET=on \
    -DARROW_BUILD_SHARED=off \
    -DARROW_BUILD_STATIC=on \
    -DARROW_BUILD_TESTS=on \
    -DARROW_BUILD_INTEGRATION=off \
    -DARROW_BUILD_BENCHMARKS=off \
    -DARROW_BUILD_EXAMPLES=off \
    -DARROW_BUILD_UTILITIES=off \
    -DARROW_TEST_LINKAGE=static \
    -DPARQUET_BUILD_EXAMPLES=off \
    -DPARQUET_BUILD_EXECUTABLES=off \
    -DPARQUET_REQUIRE_ENCRYPTION=off \
    -DARROW_WITH_BROTLI=on \
    -DARROW_WITH_BZ2=off \
    -DARROW_WITH_LZ4=on \
    -DARROW_WITH_SNAPPY=on \
    -DARROW_WITH_ZLIB=on \
    -DARROW_WITH_ZSTD=on \
    -DARROW_USE_GLOG=off \
    -DARROW_USE_ASAN=off \
    -DARROW_USE_UBSAN=off \
    -DARROW_USE_TSAN=off \
    -DARROW_FUZZING=off > /dev/null 2>&1

# Build
ninja

# Run all 48 tests
ctest --output-on-failure --timeout 120

echo "All tests passed!"
exit 0
