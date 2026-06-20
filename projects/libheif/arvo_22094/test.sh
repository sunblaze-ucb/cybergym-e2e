#!/usr/bin/env bash
# test.sh - ALL unit tests for libheif (arvo_22094)
#
# Build system: autotools (autoconf/automake)
# Test framework: Catch (v1) header-only
# Source: /src/libheif
#
# The compile.sh builds with -m32 and sanitizer flags for fuzzing,
# which produces 32-bit libs incompatible with test linking.
# We rebuild deps and libheif cleanly for test purposes.
#
# Test files:
#   - tests/conversion.cc: Color conversion pipeline tests (1 test case, 14 assertions)
#   - tests/encode.cc: Encoding tests (all disabled via #if 0 in source)
#
# Total test cases: 1 (conversion)
# Included: 1 (all pass)
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

export DEPS_PATH=/src/test-deps
mkdir -p "$DEPS_PATH"

# Rebuild x265 without sanitizer/32-bit flags
cd /src/x265/build/linux
rm -rf CMakeCache.txt CMakeFiles
cmake -G "Unix Makefiles" \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_C_FLAGS="" -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
  -DCMAKE_INSTALL_PREFIX="$DEPS_PATH" \
  -DENABLE_SHARED:bool=off \
  ../../source > /dev/null 2>&1
make -j$(nproc) x265-static > /dev/null 2>&1
make install > /dev/null 2>&1

# Rebuild libde265 without sanitizer/32-bit flags
cd /src/libde265
make clean > /dev/null 2>&1 || true
CC=clang CXX="clang++ -stdlib=libc++" CFLAGS="" CXXFLAGS="-stdlib=libc++" \
  ./configure \
  --prefix="$DEPS_PATH" \
  --disable-shared --enable-static \
  --disable-dec265 --disable-sherlock265 \
  --disable-hdrcopy --disable-enc265 \
  --disable-acceleration_speed > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
make install > /dev/null 2>&1

rm -f "$DEPS_PATH"/lib/*.so
rm -f "$DEPS_PATH"/lib/*.so.*

# Rebuild libheif with tests enabled, using libc++ consistently
cd /src/libheif
make clean > /dev/null 2>&1 || true
CC=clang CXX=clang++ CFLAGS="" CXXFLAGS="-stdlib=libc++" \
  PKG_CONFIG="pkg-config --static" PKG_CONFIG_PATH="$DEPS_PATH/lib/pkgconfig" \
  ./configure \
  --disable-shared --enable-static \
  --disable-examples --disable-go \
  --enable-tests > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1

# Run ALL unit tests
cd tests
make test-local

echo "All tests passed!"
exit 0
