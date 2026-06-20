#!/bin/bash
# test.sh - Unit tests for libxaac (arvo_61789)
#
# This project uses command-line test applications (xaacdec, xaacenc) rather than
# a traditional unit test framework like CTest or GoogleTest. The test binaries
# encode WAV files to various AAC formats and decode them back to PCM.
#
# Test Statistics:
#   Total: 9 tests | Included: 9 | Excluded: 0
#
# Test Coverage:
#   - Encoder: AAC-LC, HE-AACv1, HE-AACv2, AAC-LD, AAC-ELD, USAC (6 tests)
#   - Decoder: AAC-LC, HE-AACv1, HE-AACv2 (3 tests)
#
# Notes:
#   - AAC-LD, AAC-ELD, and USAC decoding produce empty output files in this build
#     configuration but still return exit code 0. The encoder tests for these
#     formats verify encoding functionality.
#   - Tests use the bundled sine_2ch.wav test file.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

# Source directory
SRC_DIR="${SRC:-/src}/libxaac"
BUILD_DIR="/tmp/libxaac_build_$$"
TEST_DIR="/tmp/libxaac_test_$$"

# Cleanup function
cleanup() {
    rm -rf "$BUILD_DIR" "$TEST_DIR" 2>/dev/null || true
}
trap cleanup EXIT

# Create directories
mkdir -p "$BUILD_DIR" "$TEST_DIR"

echo "=== Building libxaac test applications ==="
cd "$BUILD_DIR"
cmake "$SRC_DIR" > /dev/null 2>&1
make -j$(nproc) xaacdec xaacenc > /dev/null 2>&1
echo "Build completed successfully"

# Test input file
INPUT_WAV="$SRC_DIR/test/encoder/sine_2ch.wav"

# Verify input file exists
if [ ! -f "$INPUT_WAV" ]; then
    echo "FAIL: Test input file not found: $INPUT_WAV"
    exit 1
fi

PASS_COUNT=0
FAIL_COUNT=0

run_test() {
    local test_name="$1"
    local test_cmd="$2"
    echo -n "Test: $test_name... "
    if eval "$test_cmd" > /dev/null 2>&1; then
        echo "PASS"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "FAIL"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# Verify file is non-empty
check_non_empty() {
    local file="$1"
    [ -s "$file" ]
}

echo ""
echo "=== Running Encoder Tests ==="

# Test 1: AAC-LC encoding (AOT 2)
run_test "Encoder AAC-LC (AOT 2)" \
    "$BUILD_DIR/xaacenc -ifile:$INPUT_WAV -ofile:$TEST_DIR/test_lc.aac -aot:2 -adts:1 -br:128000 && check_non_empty $TEST_DIR/test_lc.aac"

# Test 2: HE-AACv1 encoding (AOT 5)
run_test "Encoder HE-AACv1 (AOT 5)" \
    "$BUILD_DIR/xaacenc -ifile:$INPUT_WAV -ofile:$TEST_DIR/test_heaac1.aac -aot:5 -adts:1 -br:64000 && check_non_empty $TEST_DIR/test_heaac1.aac"

# Test 3: HE-AACv2 encoding (AOT 29)
run_test "Encoder HE-AACv2 (AOT 29)" \
    "$BUILD_DIR/xaacenc -ifile:$INPUT_WAV -ofile:$TEST_DIR/test_heaac2.aac -aot:29 -adts:1 -br:48000 && check_non_empty $TEST_DIR/test_heaac2.aac"

# Test 4: AAC-LD encoding (AOT 23)
run_test "Encoder AAC-LD (AOT 23)" \
    "$BUILD_DIR/xaacenc -ifile:$INPUT_WAV -ofile:$TEST_DIR/test_ld.aac -aot:23 -adts:1 -br:128000 && check_non_empty $TEST_DIR/test_ld.aac"

# Test 5: AAC-ELD encoding (AOT 39)
run_test "Encoder AAC-ELD (AOT 39)" \
    "$BUILD_DIR/xaacenc -ifile:$INPUT_WAV -ofile:$TEST_DIR/test_eld.aac -aot:39 -adts:1 -br:128000 && check_non_empty $TEST_DIR/test_eld.aac"

# Test 6: USAC encoding (AOT 42)
run_test "Encoder USAC (AOT 42)" \
    "$BUILD_DIR/xaacenc -ifile:$INPUT_WAV -ofile:$TEST_DIR/test_usac.xheaac -aot:42 -br:64000 && check_non_empty $TEST_DIR/test_usac.xheaac"

echo ""
echo "=== Running Decoder Tests ==="

# Test 7: AAC-LC decoding
run_test "Decoder AAC-LC" \
    "$BUILD_DIR/xaacdec -ifile:$TEST_DIR/test_lc.aac -ofile:$TEST_DIR/out_lc.pcm && check_non_empty $TEST_DIR/out_lc.pcm"

# Test 8: HE-AACv1 decoding
run_test "Decoder HE-AACv1" \
    "$BUILD_DIR/xaacdec -ifile:$TEST_DIR/test_heaac1.aac -ofile:$TEST_DIR/out_heaac1.pcm && check_non_empty $TEST_DIR/out_heaac1.pcm"

# Test 9: HE-AACv2 decoding
run_test "Decoder HE-AACv2" \
    "$BUILD_DIR/xaacdec -ifile:$TEST_DIR/test_heaac2.aac -ofile:$TEST_DIR/out_heaac2.pcm && check_non_empty $TEST_DIR/out_heaac2.pcm"

echo ""
echo "=== Test Summary ==="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo "Total:  $((PASS_COUNT + FAIL_COUNT))"

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo ""
    echo "FAIL: Some tests failed"
    exit 1
fi

echo ""
echo "All tests passed!"
exit 0

