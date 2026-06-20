#!/bin/bash
# test.sh - ALL unit tests for libwebp (oss-fuzz_382816119)
#
# This script runs the COMPLETE test suite for the libwebp project.
# The tests are fuzztest-based tests that run as unit tests (GoogleTest).
#
# Test discovery method: Examined /src/libwebp/tests/fuzzer/CMakeLists.txt
# which defines 12 fuzz test targets using add_webp_fuzztest().
#
# Total tests: 12
# Included: 12
# Excluded: 0
#
# All tests pass without modification.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Set test data directory environment variable required by fuzz tests
export TEST_DATA_DIRS=/src/libwebp/tests/fuzzer/data/

# Directory containing the built fuzz test executables
FUZZER_DIR=/src/libwebp/build/tests/fuzzer

echo "Running libwebp fuzz tests (unit test mode)..."
echo "================================================"

# Run all 12 fuzz tests
# Each test is a fuzztest executable that runs as a GoogleTest unit test

echo "[1/12] Running advanced_api_fuzzer..."
$FUZZER_DIR/advanced_api_fuzzer

echo "[2/12] Running animation_api_fuzzer..."
$FUZZER_DIR/animation_api_fuzzer

echo "[3/12] Running animdecoder_fuzzer..."
$FUZZER_DIR/animdecoder_fuzzer

echo "[4/12] Running animencoder_fuzzer..."
$FUZZER_DIR/animencoder_fuzzer

echo "[5/12] Running dec_fuzzer..."
$FUZZER_DIR/dec_fuzzer

echo "[6/12] Running enc_dec_fuzzer..."
$FUZZER_DIR/enc_dec_fuzzer

echo "[7/12] Running enc_fuzzer..."
$FUZZER_DIR/enc_fuzzer

echo "[8/12] Running huffman_fuzzer..."
$FUZZER_DIR/huffman_fuzzer

echo "[9/12] Running imageio_fuzzer..."
$FUZZER_DIR/imageio_fuzzer

echo "[10/12] Running mux_demux_api_fuzzer..."
$FUZZER_DIR/mux_demux_api_fuzzer

echo "[11/12] Running simple_api_fuzzer..."
$FUZZER_DIR/simple_api_fuzzer

echo "[12/12] Running webp_info_fuzzer..."
$FUZZER_DIR/webp_info_fuzzer

echo "================================================"
echo "All tests passed!"
exit 0
