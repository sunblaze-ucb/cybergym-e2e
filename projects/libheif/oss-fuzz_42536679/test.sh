#!/bin/bash
# test.sh - ALL unit tests for libheif (oss-fuzz_42536679)
#
# This script runs the COMPLETE test suite for the libheif project.
# Only tests that genuinely fail are excluded.
#
# Excluded tests (with reasons):
#   - encode: Fails because no codec backends are available (error code 3 = no encoder found)
#   - region: Fails because it requires an encoder to create test images (error code 3)
#
# Total tests: 18
# Included: 16
# Excluded: 2
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/libheif

# Build with testing enabled
mkdir -p build_test
cd build_test

cmake .. -DBUILD_TESTING=ON \
         -DWITH_REDUCED_VISIBILITY=OFF \
         -DWITH_UNCOMPRESSED_CODEC=ON \
         -DENABLE_PLUGIN_LOADING=OFF \
         -DCMAKE_BUILD_TYPE=Debug \
         > /dev/null 2>&1

make -j$(nproc) > /dev/null 2>&1

# Run tests, excluding the failing ones (encode and region fail due to no codec backends)
# Note: Use ^ anchor to avoid excluding uncompressed_encode which passes
ctest --output-on-failure -E "^(encode|region)$"

echo "All tests passed!"
exit 0
