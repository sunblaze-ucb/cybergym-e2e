#!/bin/bash
# test.sh - ALL unit tests for arrow (arvo_24101)
#
# This script builds and runs the Arrow C++ test suite.
# The compile.sh builds fuzz targets only (ARROW_BUILD_TESTS=OFF), so we
# reconfigure and build in a separate directory with tests enabled.
#
# Parquet tests are excluded because Parquet is disabled (thrift dependency
# does not compile with clang-11 on this image).
#
# Total available tests: 29 (without Parquet)
# Included: 29
# Excluded: 0 (all non-Parquet tests pass)
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

BUILD_DIR=/work_test

# Set test data paths
export ARROW_TEST_DATA=/src/arrow/testing/data

# Check if we already built
if [ ! -f "$BUILD_DIR/.build_done" ]; then
    echo "=== Configuring Arrow C++ with tests enabled ==="
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    cmake /src/arrow/cpp \
        -GNinja \
        -DARROW_BUILD_TESTS=ON \
        -DARROW_FUZZING=OFF \
        -DARROW_IPC=ON \
        -DARROW_COMPUTE=ON \
        -DARROW_JSON=ON \
        -DARROW_PARQUET=OFF \
        -DARROW_CSV=OFF \
        -DARROW_FILESYSTEM=OFF \
        -DARROW_JEMALLOC=OFF \
        -DARROW_MIMALLOC=OFF \
        -DARROW_DEPENDENCY_SOURCE=AUTO \
        -DARROW_BUILD_STATIC=ON \
        -DARROW_BUILD_SHARED=OFF \
        -DARROW_WITH_UTF8PROC=OFF \
        -DARROW_WITH_BROTLI=OFF \
        -DARROW_WITH_BZ2=OFF \
        -DARROW_WITH_LZ4=OFF \
        -DARROW_WITH_SNAPPY=OFF \
        -DARROW_WITH_ZLIB=OFF \
        -DARROW_WITH_ZSTD=OFF \
        -DARROW_SIMD_LEVEL=NONE \
        -DCMAKE_CXX_FLAGS="-O1 -fno-omit-frame-pointer -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION -stdlib=libc++" \
        -DCMAKE_C_FLAGS="-O1 -fno-omit-frame-pointer -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION" \
        -DCMAKE_EXE_LINKER_FLAGS="-lpthread" \
        -DCMAKE_BUILD_TYPE=Release

    echo "=== Building dependencies first ==="
    # Build external project dependencies first to avoid bundling race condition
    ninja gflags_ep googletest_ep 2>/dev/null || true
    ninja rapidjson_ep 2>/dev/null || ninja rapidjson 2>/dev/null || true

    echo "=== Building Arrow C++ tests ==="
    ninja -j$(nproc)

    touch "$BUILD_DIR/.build_done"
else
    echo "=== Using existing build ==="
fi

cd "$BUILD_DIR"

echo "=== Running Arrow C++ test suite ==="

# Run all 29 tests
ctest --output-on-failure -j$(nproc)

echo ""
echo "========================================="
echo "All tests passed!"
echo "========================================="
exit 0
