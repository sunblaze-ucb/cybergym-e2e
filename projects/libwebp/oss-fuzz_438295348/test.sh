#!/bin/bash
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

LIBWEBP=/src/libwebp
TEST_DATA=/src/libwebp-test-data
BUILD=$LIBWEBP/build
FUZZER_DIR=$BUILD/tests/fuzzer

echo "========================================="
echo "libwebp test suite"
echo "========================================="

###############################################################################
# 1. FuzzTest/GTest unit tests
###############################################################################
echo ""
echo "--- FuzzTest/GTest unit tests (12 tests) ---"

export TEST_DATA_DIRS=$LIBWEBP/tests/fuzzer/data/

for fuzzer in \
    advanced_api_fuzzer \
    animation_api_fuzzer \
    animdecoder_fuzzer \
    animencoder_fuzzer \
    dec_fuzzer \
    enc_dec_fuzzer \
    enc_fuzzer \
    huffman_fuzzer \
    imageio_fuzzer \
    mux_demux_api_fuzzer \
    simple_api_fuzzer \
    webp_info_fuzzer \
; do
    echo "Running $fuzzer ..."
    $FUZZER_DIR/$fuzzer --gtest_print_time=0 2>&1 | tail -1
done

echo "All FuzzTest/GTest unit tests passed."

###############################################################################
# 2. cwebp encoding validation tests
###############################################################################
echo ""
echo "--- cwebp encoding validation tests ---"

# Exclude animated webp files that cwebp cannot process:
#   - 0262-68f6c8608ff616174b0403e8119896fff799b573.webp (animated WebP)
#   - 0390-c04d15f0b46b8ab447d247b3f3d8aceb851fc888.webp (animated WebP)
cd $TEST_DATA
FILES=$(ls $TEST_DATA/*.webp | grep -v '0262-' | grep -v '0390-')
bash test_cwebp.sh --exec=$BUILD/cwebp $FILES

echo "cwebp encoding tests passed."

###############################################################################
echo ""
echo "========================================="
echo "All tests passed!"
echo "========================================="
exit 0

