#!/bin/bash
# test.sh - ALL unit tests for gdal (arvo_4071)
#
# GDAL 2.3.0 uses autotools. The fuzzer build produces a static library with
# clang/ASAN, which is unsuitable for running the test suite. This script
# rebuilds GDAL with gcc (no sanitizers) and runs the complete C++ test suite
# from autotest/cpp/.
#
# Total C++ test groups: 14 (TEST, GDAL, AAIGrid, DTED, GTiff, OGR, Shape,
#   OSR, OSR::CT, OSR::PCI, OSR::PROJ.4, Triangulation, plus standalone tests)
# Total individual tests: 105 (via gdal_unit_test) + 9 standalone test programs
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

SRC_DIR="/src/gdal/gdal"
TEST_DIR="/src/gdal/autotest/cpp"

# Clear OSS-Fuzz environment that breaks gcc builds
unset CFLAGS CXXFLAGS LDFLAGS SANITIZER FUZZING_ENGINE ARCHITECTURE
export CFLAGS='-O2'
export CXXFLAGS='-O2'

# Reconfigure GDAL with gcc (the fuzzer build used clang with sanitizers)
cd "$SRC_DIR"
CC=gcc CXX=g++ ./configure --without-libtool --with-liblzma --with-expat \
  --with-sqlite3 --with-webp --without-hdf5 --with-jpeg=internal \
  --without-xerces --without-curl --without-netcdf --prefix=/usr/local \
  > /dev/null 2>&1

# Build and install GDAL
make clean -s 2>/dev/null || true
make -j"$(nproc)" -s 2>&1 | tail -3
make -j"$(nproc)" -s install 2>&1 | tail -3
ldconfig

# Build the C++ test suite
cd "$TEST_DIR"
make clean 2>/dev/null || true
make -j"$(nproc)" 2>&1 | tail -5

export LD_LIBRARY_PATH=/usr/local/lib
export GDAL_DATA="$SRC_DIR/data"

# Run the main unit test suite (105 individual tests across 14 groups)
echo "=== Running gdal_unit_test ==="
./gdal_unit_test

# Run standalone test programs
echo "=== Running testcopywords ==="
./testcopywords

echo "=== Running testclosedondestroydm ==="
./testclosedondestroydm

echo "=== Running testthreadcond ==="
./testthreadcond

echo "=== Running testvirtualmem ==="
./testvirtualmem

echo "=== Running testblockcache ==="
./testblockcache -check -co TILED=YES -loops 3

echo "=== Running testblockcache (HASHSET) ==="
./testblockcache --config GDAL_BAND_BLOCK_CACHE HASHSET -check -co TILED=YES -loops 3

echo "=== Running testblockcachewrite ==="
./testblockcachewrite

echo "=== Running testblockcachelimits ==="
./testblockcachelimits

echo "=== Running testmultithreadedwriting ==="
./testmultithreadedwriting

echo "=== Running testdestroy ==="
./testdestroy

echo "All tests passed!"
exit 0
