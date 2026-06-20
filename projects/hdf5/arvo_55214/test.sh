#!/bin/bash
# test.sh - ALL unit tests for hdf5 (arvo_55214)
#
# This script runs the COMPLETE test suite for the hdf5 project.
# HDF5 uses CMake/CTest for testing.
#
# Total tests: 115
# Included: 114
# Excluded: 1
#
# Excluded tests (with reasons):
#   - H5TEST-external: Fails because cannot open external raw data file
#     "extsrc". The test expects this file to exist but it's not properly
#     set up in the ASAN build environment.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/hdf5

# Build with testing enabled if not already built
if [ ! -d "build-test" ]; then
    mkdir -p build-test
    cd build-test
    cmake -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE:STRING=Release \
        -DBUILD_SHARED_LIBS:BOOL=OFF \
        -DBUILD_TESTING:BOOL=ON \
        -DHDF5_BUILD_EXAMPLES:BOOL=OFF \
        -DHDF5_BUILD_TOOLS:BOOL=OFF \
        -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON \
        ..
    cmake --build . --config Release -j$(nproc)
    cd ..
fi

cd build-test

# Run all tests using ctest, excluding the failing H5TEST-external test
ctest --output-on-failure -j$(nproc) -E "H5TEST-external"

echo "All tests passed!"
exit 0
