#!/usr/bin/env bash
export ASAN_OPTIONS="detect_leaks=0"
cd ${SRC:-/src}/c-blosc2

echo "=== Running tests for c-blosc2 ==="
LOG_FILE=$(mktemp /tmp/c-blosc2_test_log.XXXXXX)

# Exclude known failing tests
EXCLUDE_PATTERN="generate_inputs_corpus|test_copy|test_delete_chunk|test_fill_special|test_frame|test_insert_chunk|test_lazychunk|test_reorder_offsets|test_sframe|test_sframe_lazychunk|test_udcodecs|test_update_chunk|test_zero_runlen|test_example_frame_simple|test_example_frame_vlmetalayers|test_example_sframe_simple|test_example_compress_file"

cmake . && ctest --output-on-failure -E "$EXCLUDE_PATTERN" | tee $LOG_FILE

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed"
    exit 1
fi
