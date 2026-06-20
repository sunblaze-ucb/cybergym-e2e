#!/bin/bash
# test.sh - ALL unit tests for libavc (arvo_27856)
#
# libavc does not have a traditional unit test suite (no make check, ctest, etc.).
# It provides a decoder CLI (avcdec) and an encoder CLI (avcenc) as test applications.
# Tests are performed by:
#   1. Building the project from source using cmake
#   2. Running the decoder on the H264 seed corpus (628 files)
#   3. Running the encoder with multiple configurations
#   4. Running encode-decode roundtrip tests
#
# Excluded decoder samples (8 out of 628 - malformed H264 that cause parse errors):
#   - 065aa611187ec6933b2ae198efe9276014b0b35a: Error in header decode
#   - 0bed19c04757f88f73db67e2e1142efa6a409bbd: Error in header decode
#   - 49300bd16ff6395bf77e01acfc257a29a90c8022: Error in header decode
#   - 4f8223683bb8e0338877f91663421504eea88fb2: Error in header decode
#   - 57a63c6f95144a138449d33314e73415cf29efc3: Error in header decode
#   - 89b977c15309926ae17ff6089fe549dfd41afec5: Error in header decode
#   - 9af933100f9a1fc0d680caf3784d888129b6458d: Error in header decode
#   - b1a8580b2d23ec5de1e2d0eede7100a05743de7b: Error in header decode
#
# Total tests: 628 decoder + 4 encoder + 4 roundtrip = 636
# Included: 620 decoder + 4 encoder + 4 roundtrip = 628
# Excluded: 8 decoder (malformed H264 input)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

SRC_DIR="${SRC:-/src}/libavc"
BUILD_DIR="/tmp/libavc_build"
TEST_DATA_DIR="/tmp/libavc_test_data"
SEED_CORPUS="/src/avc_dec_fuzzer_seed_corpus.zip"

# Known failing decoder samples (malformed H264 that cause parse errors)
EXCLUDED_SAMPLES="065aa611187ec6933b2ae198efe9276014b0b35a
0bed19c04757f88f73db67e2e1142efa6a409bbd
49300bd16ff6395bf77e01acfc257a29a90c8022
4f8223683bb8e0338877f91663421504eea88fb2
57a63c6f95144a138449d33314e73415cf29efc3
89b977c15309926ae17ff6089fe549dfd41afec5
9af933100f9a1fc0d680caf3784d888129b6458d
b1a8580b2d23ec5de1e2d0eede7100a05743de7b"

PASS=0
FAIL=0
TOTAL=0

fail_test() {
    echo "FAIL: $1"
    FAIL=$((FAIL+1))
    TOTAL=$((TOTAL+1))
}

pass_test() {
    PASS=$((PASS+1))
    TOTAL=$((TOTAL+1))
}

# ============================================================
# Step 1: Build the project
# ============================================================
echo "=== Building libavc from source ==="
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
cmake "$SRC_DIR" > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1

if [ ! -x "$BUILD_DIR/avcdec" ] || [ ! -x "$BUILD_DIR/avcenc" ]; then
    echo "FAIL: Build did not produce avcdec and avcenc binaries"
    exit 1
fi
echo "Build successful."

# ============================================================
# Step 2: Extract seed corpus for decoder tests
# ============================================================
echo "=== Extracting H264 test data ==="
rm -rf "$TEST_DATA_DIR"
mkdir -p "$TEST_DATA_DIR/h264"
cd "$TEST_DATA_DIR"
unzip -o -j "$SEED_CORPUS" 'h264/*' -d h264/ > /dev/null 2>&1
SAMPLE_COUNT=$(ls h264/ | wc -l)
echo "Extracted $SAMPLE_COUNT H264 test samples."

# ============================================================
# Step 3: Decoder tests - run on all seed corpus samples
# ============================================================
echo "=== Running decoder tests on seed corpus ==="
is_excluded() {
    echo "$EXCLUDED_SAMPLES" | grep -qF "$1"
}

for f in $(ls "$TEST_DATA_DIR/h264/"); do
    if is_excluded "$f"; then
        continue
    fi
    if "$BUILD_DIR/avcdec" --input "$TEST_DATA_DIR/h264/$f" --output /dev/null --num_frames 10 > /dev/null 2>&1; then
        pass_test
    else
        fail_test "decoder: $f"
    fi
done
echo "Decoder tests done: $PASS passed, $FAIL failed."

# ============================================================
# Step 4: Encoder tests - multiple configurations
# ============================================================
echo "=== Running encoder tests ==="

# Test 1: 64x64 YUV420P CAVLC
dd if=/dev/urandom of=/tmp/test_enc_64x64.yuv bs=$((64*64*3/2)) count=3 2>/dev/null
if "$BUILD_DIR/avcenc" --input /tmp/test_enc_64x64.yuv --output /tmp/enc_out1.264 \
    --width 64 --height 64 --num_frames 3 --input_chroma_format YUV_420P \
    --max_wd 64 --max_ht 64 --rc 0 --qp_i 24 --qp_p 27 --qp_b 29 --entropy 0 > /dev/null 2>&1; then
    pass_test
else
    fail_test "encoder: 64x64 CAVLC"
fi

# Test 2: 128x128 YUV420P CAVLC
dd if=/dev/urandom of=/tmp/test_enc_128x128.yuv bs=$((128*128*3/2)) count=3 2>/dev/null
if "$BUILD_DIR/avcenc" --input /tmp/test_enc_128x128.yuv --output /tmp/enc_out2.264 \
    --width 128 --height 128 --num_frames 3 --input_chroma_format YUV_420P \
    --max_wd 128 --max_ht 128 --rc 0 --qp_i 24 --qp_p 27 --qp_b 29 --entropy 0 > /dev/null 2>&1; then
    pass_test
else
    fail_test "encoder: 128x128 CAVLC"
fi

# Test 3: 320x240 YUV420P CAVLC
dd if=/dev/urandom of=/tmp/test_enc_320x240.yuv bs=$((320*240*3/2)) count=2 2>/dev/null
if "$BUILD_DIR/avcenc" --input /tmp/test_enc_320x240.yuv --output /tmp/enc_out3.264 \
    --width 320 --height 240 --num_frames 2 --input_chroma_format YUV_420P \
    --max_wd 320 --max_ht 240 --rc 0 --qp_i 24 --qp_p 27 --qp_b 29 --entropy 0 > /dev/null 2>&1; then
    pass_test
else
    fail_test "encoder: 320x240 CAVLC"
fi

# Test 4: 64x64 YUV420P CABAC
if "$BUILD_DIR/avcenc" --input /tmp/test_enc_64x64.yuv --output /tmp/enc_out4.264 \
    --width 64 --height 64 --num_frames 3 --input_chroma_format YUV_420P \
    --max_wd 64 --max_ht 64 --rc 0 --qp_i 24 --qp_p 27 --qp_b 29 --entropy 1 > /dev/null 2>&1; then
    pass_test
else
    fail_test "encoder: 64x64 CABAC"
fi

echo "Encoder tests done."

# ============================================================
# Step 5: Encode-decode roundtrip tests
# ============================================================
echo "=== Running encode-decode roundtrip tests ==="

for i in 1 2 3 4; do
    if "$BUILD_DIR/avcdec" --input /tmp/enc_out${i}.264 --output /dev/null > /dev/null 2>&1; then
        pass_test
    else
        fail_test "roundtrip decode: enc_out${i}.264"
    fi
done

echo "Roundtrip tests done."

# ============================================================
# Summary
# ============================================================
echo ""
echo "=== Test Summary ==="
echo "Total:   $TOTAL"
echo "Passed:  $PASS"
echo "Failed:  $FAIL"

if [ "$FAIL" -gt 0 ]; then
    echo "SOME TESTS FAILED"
    exit 1
fi

echo "All tests passed!"
exit 0
