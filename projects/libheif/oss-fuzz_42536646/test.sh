#!/bin/bash
# test.sh - ALL unit tests for libheif (oss-fuzz_42536646)
#
# This script runs the COMPLETE test suite for the libheif project.
# Only tests that genuinely fail are excluded.
#
# Total tests: 18
# Included: 16
# Excluded: 2
#
# Excluded tests (with reasons):
#   - encode: Requires an encoder (HEVC/AV1) to be available, but no encoder
#             codecs are built in this container. Test fails with error code 3
#             (heif_error_Encoder_plugin_not_loaded).
#   - region: Also requires an encoder to create images for region testing.
#             Fails with error code 3 (heif_error_Encoder_plugin_not_loaded).
#
# Included tests:
#   - box_equals
#   - conversion
#   - idat
#   - jpeg2000
#   - avc_box
#   - uncompressed_box
#   - uncompressed_decode
#   - uncompressed_decode_mono
#   - uncompressed_decode_rgb
#   - uncompressed_decode_rgb16
#   - uncompressed_decode_rgb565
#   - uncompressed_decode_rgb7
#   - uncompressed_decode_ycbcr
#   - uncompressed_decode_ycbcr420
#   - uncompressed_decode_ycbcr422
#   - uncompressed_encode
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/libheif

# Create build directory and configure with testing preset
mkdir -p build_test
cd build_test

cmake .. --preset=testing >/dev/null 2>&1

# Build the project and tests
make -j$(nproc) >/dev/null 2>&1

# Run all tests excluding known failures
# The 'encode' and 'region' tests fail because no encoder plugins are available
# Use anchored regex to avoid excluding 'uncompressed_encode'
ctest --output-on-failure -E "^(encode|region)$"

echo "All tests passed!"
exit 0
