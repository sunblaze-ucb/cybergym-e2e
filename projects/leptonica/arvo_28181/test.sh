#!/bin/bash
# test.sh - ALL unit tests for leptonica (arvo_28181)
#
# Build image: gcr.io/oss-fuzz-base/base-builder@sha256:fba1033c6a64433642ab97b6ea987ddaa9938e06596c6cace1c786130fc1461b
#
# This script rebuilds leptonica with gcc (no sanitizers) using autotools
# and runs the complete test suite via 'make check'. The fuzzer build from
# compile.sh uses MSan/libfuzzer which is incompatible with running unit tests.
#
# Test Statistics:
#   Total tests: 144 (AUTO_REG_PROGS from Makefile.am)
#   Included: 144 (119 PASS + 25 SKIP due to missing gnuplot)
#   Excluded: 0
#   Failed: 0
#
# Tests that SKIP (exit code 77, not failures - gnuplot not available):
#   baseline_reg, boxa1_reg, boxa2_reg, boxa3_reg, boxa4_reg,
#   colormask_reg, colorspace_reg, crop_reg, dna_reg, enhance_reg,
#   extrema_reg, fpix1_reg, hash_reg, italic_reg, kernel_reg,
#   nearline_reg, numa1_reg, numa2_reg, numa3_reg, pixa1_reg,
#   projection_reg, rank_reg, rankbin_reg, rankhisto_reg, wordboxes_reg
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

SRC=${SRC:-/src}
WORK=/tmp/test_work
mkdir -p $WORK/lib $WORK/include

# Use gcc to avoid sanitizer interference from the fuzzer build
export CC=gcc
export CXX=g++
export CFLAGS="-fPIC -O2"
export CXXFLAGS="-fPIC -O2"

echo "=== Building dependencies ==="

# Build zlib
cd $SRC/zlib
make distclean 2>/dev/null || true
CFLAGS="-fPIC -O2" ./configure --static --prefix=$WORK
make -j$(nproc)
make install

# Build libjpeg-turbo (remove cmake cache from fuzzer build)
cd $SRC/libjpeg-turbo
make clean 2>/dev/null || true
rm -f CMakeCache.txt
rm -rf CMakeFiles
cmake . -DCMAKE_INSTALL_PREFIX=$WORK -DENABLE_STATIC:bool=on \
  -DCMAKE_C_COMPILER=gcc -DCMAKE_C_FLAGS="-fPIC"
make -j$(nproc)
make install

# Build libpng
cd $SRC/libpng
make clean 2>/dev/null || true
make distclean 2>/dev/null || true
autoreconf -f -i
./configure --prefix=$WORK --disable-shared --enable-static \
  LDFLAGS="-L$WORK/lib" CPPFLAGS="-I$WORK/include" CFLAGS="-fPIC -O2" CC=gcc
make -j$(nproc)
make install

# Build libwebp
cd $SRC/libwebp
make clean 2>/dev/null || true
make distclean 2>/dev/null || true
./autogen.sh
./configure --enable-libwebpdemux --enable-libwebpmux --disable-shared \
  --disable-jpeg --disable-tiff --disable-gif --disable-wic --disable-threading \
  --prefix=$WORK CFLAGS="-fPIC -O2" CC=gcc
make -j$(nproc)
make install

# Build libtiff (remove cmake cache from fuzzer build)
cd $SRC/libtiff
make clean 2>/dev/null || true
rm -f CMakeCache.txt
rm -rf CMakeFiles
cmake . -DCMAKE_INSTALL_PREFIX=$WORK -DBUILD_SHARED_LIBS=off \
  -DCMAKE_C_COMPILER=gcc -DCMAKE_C_FLAGS="-fPIC"
make -j$(nproc)
make install

# Build jbigkit
cd $SRC/jbigkit
make clean 2>/dev/null || true
make -j$(nproc) lib CFLAGS="-fPIC -O2"
cp $SRC/jbigkit/libjbig/*.a $WORK/lib/
cp $SRC/jbigkit/libjbig/*.h $WORK/include/

# Build zstd
cd $SRC/zstd
make clean 2>/dev/null || true
make -j$(nproc) lib CFLAGS="-fPIC -O2"
cp lib/libzstd.a $WORK/lib/
cp lib/zstd.h lib/zstd_errors.h lib/zdict.h $WORK/include/ 2>/dev/null || true

echo "=== Configuring and building leptonica for testing ==="
export PKG_CONFIG_PATH=$WORK/lib/pkgconfig:$WORK/lib/x86_64-linux-gnu/pkgconfig
cd $SRC/leptonica
make distclean 2>/dev/null || true
./autogen.sh
./configure \
  --with-libpng \
  --with-zlib \
  --with-jpeg \
  --with-libwebp \
  --with-libtiff \
  --prefix=$WORK \
  LIBS="$WORK/lib/libjbig.a $WORK/lib/libzstd.a" \
  LDFLAGS="-L$WORK/lib" \
  CPPFLAGS="-I$WORK/include" \
  CFLAGS="-fPIC -O2" \
  CC=gcc CXX=g++
make -j$(nproc)

echo "=== Running full test suite (make check) ==="
# Set LD_LIBRARY_PATH so dynamically linked test binaries can find
# liblept.so and libjpeg.so at runtime
export LD_LIBRARY_PATH=$SRC/leptonica/src/.libs:$WORK/lib
make check

echo "All tests passed!"
exit 0
