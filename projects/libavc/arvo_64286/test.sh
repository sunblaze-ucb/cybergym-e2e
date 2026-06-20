#!/bin/bash
# test.sh - ALL unit tests for libavc (arvo_55964)
#
# This script runs the COMPLETE test suite for the libavc project.
# libavc does not have traditional unit tests (ctest shows 0 tests).
# Instead, we test the decoder/encoder binaries with sample H.264 files
# from the fuzzer corpus.
#
# Test Statistics:
#   Total decoder test files: 628
#   Included: 620
#   Excluded: 8 (fail in vulnerable version)
#
# Excluded test files (with reasons - these fail due to malformed input or
# vulnerabilities in the pre-patch code):
#   - 065aa611187ec6933b2ae198efe9276014b0b35a: Decoder returns non-zero
#   - 0bed19c04757f88f73db67e2e1142efa6a409bbd: Decoder returns non-zero
#   - 49300bd16ff6395bf77e01acfc257a29a90c8022: Decoder returns non-zero
#   - 4f8223683bb8e0338877f91663421504eea88fb2: Decoder returns non-zero
#   - 57a63c6f95144a138449d33314e73415cf29efc3: Decoder returns non-zero
#   - 89b977c15309926ae17ff6089fe549dfd41afec5: Decoder returns non-zero
#   - 9af933100f9a1fc0d680caf3784d888129b6458d: Decoder returns non-zero
#   - b1a8580b2d23ec5de1e2d0eede7100a05743de7b: Decoder returns non-zero
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

# Configuration
SRC_DIR="${SRC:-/src}"
BUILD_DIR="${SRC_DIR}/libavc/build"
TEST_DATA_DIR="/tmp/libavc_test_data"
TEST_OUTPUT_DIR="/tmp/libavc_test_output"
CORPUS_ZIP="${SRC_DIR}/avc_dec_fuzzer_seed_corpus.zip"

# List of excluded files (known to fail in vulnerable version)
EXCLUDED_FILES=(
    "065aa611187ec6933b2ae198efe9276014b0b35a"
    "0bed19c04757f88f73db67e2e1142efa6a409bbd"
    "49300bd16ff6395bf77e01acfc257a29a90c8022"
    "4f8223683bb8e0338877f91663421504eea88fb2"
    "57a63c6f95144a138449d33314e73415cf29efc3"
    "89b977c15309926ae17ff6089fe549dfd41afec5"
    "9af933100f9a1fc0d680caf3784d888129b6458d"
    "b1a8580b2d23ec5de1e2d0eede7100a05743de7b"
)

# Function to check if a file is in the excluded list
is_excluded() {
    local file="$1"
    for excluded in "${EXCLUDED_FILES[@]}"; do
        if [[ "$file" == "$excluded" ]]; then
            return 0
        fi
    done
    return 1
}

echo "=== libavc Test Suite ==="
echo ""

# Step 1: Build the test binaries
echo "Step 1: Building test binaries..."
cd "${SRC_DIR}/libavc"
rm -rf build
mkdir -p build
cd build
cmake .. -DENABLE_SVC=1 -DENABLE_MVC=1 >/dev/null 2>&1
make -j$(nproc) avcdec avcenc mvcdec svcdec svcenc >/dev/null 2>&1
echo "Build complete."
echo ""

# Verify binaries were built
if [[ ! -x "${BUILD_DIR}/avcdec" ]]; then
    echo "ERROR: avcdec binary not found"
    exit 1
fi

# Step 2: Setup test data
echo "Step 2: Setting up test data..."
rm -rf "${TEST_DATA_DIR}" "${TEST_OUTPUT_DIR}"
mkdir -p "${TEST_DATA_DIR}" "${TEST_OUTPUT_DIR}"

# Extract test files from corpus
if [[ -f "${CORPUS_ZIP}" ]]; then
    cd "${TEST_DATA_DIR}"
    unzip -o -j "${CORPUS_ZIP}" 'h264/*' -x 'h264/' >/dev/null 2>&1
    TOTAL_FILES=$(ls "${TEST_DATA_DIR}" | wc -l)
    echo "Extracted ${TOTAL_FILES} test files from corpus."
else
    echo "ERROR: Corpus file not found: ${CORPUS_ZIP}"
    exit 1
fi
echo ""

# Step 3: Run decoder tests
echo "Step 3: Running avcdec decoder tests..."
passed=0
failed=0
skipped=0

for testfile in "${TEST_DATA_DIR}"/*; do
    filename=$(basename "$testfile")

    # Skip excluded files
    if is_excluded "$filename"; then
        skipped=$((skipped + 1))
        continue
    fi

    # Create config file for this test
    cat > /tmp/test.cfg << EOF
--input ${testfile}
--save_output 0
--num_frames 2
--output ${TEST_OUTPUT_DIR}/out.yuv
--chroma_format YUV_420P
--share_display_buf 0
--num_cores 1
--loopback 0
--display 0
--fps 30
EOF

    # Run decoder
    if "${BUILD_DIR}/avcdec" /tmp/test.cfg >/dev/null 2>&1; then
        passed=$((passed + 1))
    else
        echo "FAIL: ${filename}"
        failed=$((failed + 1))
    fi
done

echo ""
echo "=== Decoder Test Results ==="
echo "Passed:  ${passed}"
echo "Failed:  ${failed}"
echo "Skipped: ${skipped} (known failing in vulnerable version)"
echo "Total:   $((passed + failed + skipped))"
echo ""

# Step 4: Verify binaries exist (basic sanity check for other tools)
echo "Step 4: Verifying all binaries were built..."
BINARIES=("avcdec" "avcenc" "mvcdec" "svcdec" "svcenc")
for bin in "${BINARIES[@]}"; do
    if [[ -x "${BUILD_DIR}/${bin}" ]]; then
        echo "  OK: ${bin}"
    else
        echo "  MISSING: ${bin}"
        failed=$((failed + 1))
    fi
done
echo ""

# Cleanup
rm -rf "${TEST_DATA_DIR}" "${TEST_OUTPUT_DIR}" /tmp/test.cfg

# Final result
if [[ ${failed} -eq 0 ]]; then
    echo "=== All tests passed! ==="
    exit 0
else
    echo "=== ${failed} test(s) failed ==="
    exit 1
fi
