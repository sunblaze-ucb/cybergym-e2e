#!/usr/bin/env bash

# Prepare.sh for arrow arvo_24101
# Install missing dependencies and downgrade clang to version 11
# (the Arrow code from 2020 doesn't compile with clang 22 due to
# flatbuffers vendored header issues with deleted operator=)

set -ex

# Install ninja-build, boost, and clang-11 with libc++
apt-get update -y
apt-get install -y ninja-build libboost-all-dev clang-11 libc++-11-dev libc++abi-11-dev

# Override clang symlinks to point to clang-11
# This ensures the build uses the compatible compiler version
ln -sf /usr/bin/clang-11 /usr/local/bin/clang
ln -sf /usr/bin/clang++-11 /usr/local/bin/clang++

# Create build.sh that the compile function sources
cat > /src/build.sh << 'BUILDEOF'

set -ex
ARROW=${SRC}/arrow/cpp
cd ${WORK}
export ASAN_OPTIONS="detect_leaks=0"
cmake ${ARROW} -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DARROW_DEPENDENCY_SOURCE=BUNDLED \
    -DBOOST_SOURCE=SYSTEM \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DARROW_SIMD_LEVEL=NONE \
    -DARROW_EXTRA_ERROR_CONTEXT=off \
    -DARROW_JEMALLOC=off \
    -DARROW_MIMALLOC=off \
    -DARROW_FILESYSTEM=off \
    -DARROW_PARQUET=off \
    -DARROW_BUILD_SHARED=off \
    -DARROW_BUILD_STATIC=on \
    -DARROW_BUILD_TESTS=off \
    -DARROW_BUILD_INTEGRATION=off \
    -DARROW_BUILD_BENCHMARKS=off \
    -DARROW_BUILD_EXAMPLES=off \
    -DARROW_BUILD_UTILITIES=off \
    -DARROW_TEST_LINKAGE=static \
    -DPARQUET_BUILD_EXAMPLES=off \
    -DPARQUET_BUILD_EXECUTABLES=off \
    -DPARQUET_REQUIRE_ENCRYPTION=off \
    -DARROW_WITH_BROTLI=off \
    -DARROW_WITH_BZ2=off \
    -DARROW_WITH_LZ4=off \
    -DARROW_WITH_SNAPPY=off \
    -DARROW_WITH_ZLIB=off \
    -DARROW_WITH_ZSTD=off \
    -DARROW_USE_GLOG=off \
    -DARROW_USE_ASAN=off \
    -DARROW_USE_UBSAN=off \
    -DARROW_USE_TSAN=off \
    -DARROW_FUZZING=on
cmake --build .
cp -a release/* ${OUT}
${ARROW}/build-support/fuzzing/generate_corpuses.sh ${OUT} || true
BUILDEOF

chmod +x /src/build.sh

echo "prepare.sh completed successfully"
