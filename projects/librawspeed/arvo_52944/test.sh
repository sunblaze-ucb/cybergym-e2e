#!/bin/bash
# test.sh - ALL unit tests for librawspeed (arvo_52944)
#
# This script runs the COMPLETE test suite for the librawspeed project.
# The project uses CMake/CTest with GoogleTest framework.
#
# Total tests: 23
# Included: 23 (ALL)
# Excluded: 0
#
# Tests included:
#   - ChecksumFileTest
#   - CommonTest
#   - CpuidTest
#   - MemoryTest
#   - NORangesSetTest
#   - PointTest
#   - RangeTest
#   - SplineTest
#   - AbstractHuffmanTableTest
#   - BinaryHuffmanTreeTest
#   - HuffmanTableTest
#   - BitPumpJPEGTest
#   - BitPumpLSBTest
#   - BitPumpMSB16Test
#   - BitPumpMSB32Test
#   - BitPumpMSBTest
#   - EndiannessTest
#   - BlackAreaTest
#   - CameraMetaDataTest
#   - CameraSensorInfoTest
#   - CameraTest
#   - ColorFilterArrayTest
#   - RawSpeed
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Navigate to source directory
cd /src/librawspeed

# Create build directory and configure CMake
BUILD_DIR=/tmp/rawspeed_build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure CMake with tests enabled
# Disabling optional dependencies (JPEG, ZLIB, PUGIXML, OPENMP) that are not
# available in the container, and enabling Google Test download
cmake \
    -DBUILD_TESTING=ON \
    -DALLOW_DOWNLOADING_GOOGLETEST=ON \
    -DBUILD_TOOLS=OFF \
    -DBUILD_FUZZERS=OFF \
    -DBUILD_BENCHMARKING=OFF \
    -DWITH_OPENMP=OFF \
    -DWITH_PUGIXML=OFF \
    -DWITH_JPEG=OFF \
    -DWITH_ZLIB=OFF \
    -DUSE_XMLLINT=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS='-pthread' \
    -DCMAKE_EXE_LINKER_FLAGS='-lpthread' \
    -DRAWSPEED_ENABLE_WERROR=OFF \
    /src/librawspeed

# Build the project and tests
make -j$(nproc)

# Run all tests
ctest --output-on-failure

echo "All tests passed!"
exit 0
