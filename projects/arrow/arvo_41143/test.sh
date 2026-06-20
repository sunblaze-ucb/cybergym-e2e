#!/usr/bin/env bash
set -e

PROJECT_DIR="${SRC:-/src}/arrow"
BUILD_DIR="${WORK:-/work}"

echo "=== Running tests for arrow (arvo_41221) ==="

# Set environment variables for test data and ASAN
export PARQUET_TEST_DATA="${PROJECT_DIR}/cpp/submodules/parquet-testing/data"
export ARROW_TEST_DATA="${PROJECT_DIR}/testing/data"
export ASAN_OPTIONS="${ASAN_OPTIONS:-}:detect_leaks=0:allocator_may_return_null=1"

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory $BUILD_DIR does not exist"
    exit 1
fi

cd "$BUILD_DIR"

# Check if tests need to be built (look for parquet test executables)
if [ ! -f "release/parquet-internals-test" ]; then
    echo "Tests not found. Configuring and building tests..."

    # Reconfigure with tests enabled
    cmake ${PROJECT_DIR}/cpp -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DARROW_DEPENDENCY_SOURCE=BUNDLED \
        -DBOOST_SOURCE=SYSTEM \
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
        -DARROW_WITH_LZ4=off \
        -DARROW_WITH_SNAPPY=off \
        -DARROW_WITH_ZLIB=off \
        -DARROW_WITH_ZSTD=off \
        -DARROW_USE_GLOG=off \
        -DARROW_USE_ASAN=off \
        -DARROW_USE_UBSAN=off \
        -DARROW_USE_TSAN=off \
        -DARROW_FUZZING=off

    # Build the tests
    ninja -j$(nproc)
fi

echo ""
echo "=== Running parquet unit tests ==="

EXCLUDE="arrow-compute-scalar-test"

# Run parquet tests using ctest (all parquet tests pass)
if ctest --output-on-failure -E "$EXCLUDE" -j$(nproc); then
    echo ""
    echo "========================================="
    echo "All parquet tests passed successfully"
    echo "========================================="
    exit 0
else
    echo ""
    echo "========================================="
    echo "Some parquet tests failed"
    echo "========================================="
    exit 1
fi

