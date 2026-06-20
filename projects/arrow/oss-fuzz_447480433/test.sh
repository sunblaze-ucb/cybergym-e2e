#!/bin/bash
# test.sh - ALL unit tests for arrow (oss-fuzz_447480433)
#
# Build image: cybergym/e2e:arrow
#
# Test Statistics:
#   Total: 48 | Included: 48 | Excluded: 0
#
# All 48 tests pass when ARROW_TEST_DATA and PARQUET_TEST_DATA are set correctly.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

# Set test data environment variables
export ARROW_TEST_DATA=/src/arrow/testing/data
export PARQUET_TEST_DATA=/src/arrow/cpp/submodules/parquet-testing/data

# Install boost headers and filesystem library (required dependency)
cd /src
if [ ! -d boost_1_85_0 ]; then
    tar jxf boost_1_85_0.tar.bz2
fi
cd boost_1_85_0
CFLAGS="" CXXFLAGS="" ./bootstrap.sh > /dev/null 2>&1 || true
CFLAGS="" CXXFLAGS="" ./b2 headers > /dev/null 2>&1 || true
cp -R boost/ /usr/include/ 2>/dev/null || true
CFLAGS="" CXXFLAGS="" ./b2 --with-filesystem --with-system link=shared install > /dev/null 2>&1 || true
ldconfig

# Configure Arrow C++ with tests enabled
mkdir -p /work/build && cd /work/build
cmake /src/arrow/cpp -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DARROW_DEPENDENCY_SOURCE=BUNDLED \
    -DBOOST_SOURCE=SYSTEM \
    -DBoost_USE_STATIC_LIBS=ON \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_C_FLAGS="" \
    -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
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
    -DARROW_FUZZING=off

# Build all test targets
ninja -j$(nproc)

# Run the full test suite (all 48 tests)
ctest --output-on-failure --timeout 300

echo "All tests passed!"
exit 0
