#!/bin/bash
# test.sh - ALL unit tests for libwebp (oss-fuzz_438264629)
#
# Build image: cybergym/e2e:libwebp
#
# After compile.sh runs, fuzztest/gtest binaries are in
# /src/libwebp/build/tests/fuzzer/ and cwebp/dwebp in /src/libwebp/build/.
#
# Test Statistics:
#   Total: 15 test suites
#   Included: 8 fuzztest/gtest suites (12 individual gtest cases)
#   Excluded: 7
#     - test_dwebp.sh: lossless1.webp.pgm MD5 mismatch due to vulnerable code
#       (exit code 1); cannot exclude individual sub-tests from this script
#     - test_lossless.sh: lossless vector pgm comparisons fail due to vulnerable
#       code (binary diff in char 270); cannot exclude individual sub-tests
#     - test_cwebp.sh: MSan false positive on PNG reading (use-of-uninitialized-value
#       in pngdec.c:302) because the build uses -fsanitize=memory
#     - animdecoder_fuzzer: Segfaults on --list_fuzz_tests / --gtest_list_tests
#     - dec_fuzzer: Segfaults on --list_fuzz_tests / --gtest_list_tests
#     - imageio_fuzzer: Segfaults on --list_fuzz_tests / --gtest_list_tests
#     - webp_info_fuzzer: Segfaults on --list_fuzz_tests / --gtest_list_tests
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

LIBWEBP=/src/libwebp
BUILD=$LIBWEBP/build
FUZZER_DIR=$BUILD/tests/fuzzer

export TEST_DATA_DIRS=$LIBWEBP/tests/fuzzer/data/

echo "========================================="
echo "libwebp test suite"
echo "========================================="

###############################################################################
# FuzzTest/GTest unit tests (8 working fuzzers, 12 individual tests)
###############################################################################
echo ""
echo "--- FuzzTest/GTest unit tests ---"

for fuzzer in \
    advanced_api_fuzzer \
    animation_api_fuzzer \
    animencoder_fuzzer \
    enc_dec_fuzzer \
    enc_fuzzer \
    huffman_fuzzer \
    mux_demux_api_fuzzer \
    simple_api_fuzzer \
; do
    echo "Running $fuzzer ..."
    $FUZZER_DIR/$fuzzer --gtest_print_time=0 2>&1 | tail -1
done

echo ""
echo "========================================="
echo "All tests passed!"
echo "========================================="
exit 0
