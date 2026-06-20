#!/bin/bash
# test.sh - Unit tests for freetype2 (arvo_759)
#
# FreeType2 does not have a standard test suite (no `make check`, `make test`, or ctest tests).
# The project provides standalone test programs in src/tools/ that need to be compiled manually.
#
# Available test programs:
#   - test_trig.c: Tests trigonometry functions (FT_Cos, FT_Sin, FT_Tan, FT_Atan2, etc.)
#   - test_bbox.c: Tests bounding box computation functions (FT_Outline_Get_BBox, FT_Outline_Get_CBox)
#   - test_afm.c: Tests AFM file parsing (requires AFM file as input)
#
# Included tests:
#   - test_trig: Trigonometry function tests
#   - test_bbox: Bounding box computation tests
#
# Excluded tests:
#   - test_afm: Excluded because it requires an AFM file as input, and no AFM files
#               are available in the test environment. This is not a failure - just
#               missing test data.
#
# Note: test_trig.c has a bug in its return code logic (returns !error instead of error),
# so it returns 1 on success and 0 on failure. We check for the success message instead.
#
# Total test programs: 3
# Included: 2
# Excluded: 1
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

SRC_DIR="${SRC:-/src}"
FT2_DIR="$SRC_DIR/freetype2"
BUILD_DIR="$FT2_DIR/build"
TOOLS_DIR="$FT2_DIR/src/tools"

echo "=== Building FreeType2 library ==="
cd "$FT2_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
cmake .. > /dev/null 2>&1
make -j$(nproc) > /dev/null 2>&1
echo "Library built successfully"

echo ""
echo "=== Compiling test programs ==="
cd "$TOOLS_DIR"

# Compile test_trig
echo "Compiling test_trig..."
clang -I"$FT2_DIR/include" -I"$BUILD_DIR/include" -L"$BUILD_DIR" \
    -o test_trig test_trig.c -lfreetype -lm 2>/dev/null
echo "test_trig compiled"

# Compile test_bbox
echo "Compiling test_bbox..."
clang -I"$FT2_DIR/include" -I"$BUILD_DIR/include" -L"$BUILD_DIR" \
    -o test_bbox test_bbox.c -lfreetype -lm 2>/dev/null
echo "test_bbox compiled"

echo ""
echo "=== Running tests ==="

# Run test_trig
# Note: test_trig has a bug where it returns !error (1 on success, 0 on failure)
# So we check for the success message in output instead of exit code
echo "Running test_trig..."
TRIG_OUTPUT=$("$TOOLS_DIR/test_trig" 2>&1) || true
if echo "$TRIG_OUTPUT" | grep -q "trigonometry test ok"; then
    echo "test_trig: PASSED"
else
    echo "test_trig: FAILED"
    echo "$TRIG_OUTPUT"
    exit 1
fi

# Run test_bbox
echo "Running test_bbox..."
"$TOOLS_DIR/test_bbox" > /dev/null 2>&1
echo "test_bbox: PASSED"

# Clean up compiled test binaries
rm -f "$TOOLS_DIR/test_trig" "$TOOLS_DIR/test_bbox"

echo ""
echo "=== Test Summary ==="
echo "Tests run: 2"
echo "Tests passed: 2"
echo "Tests excluded: 1 (test_afm - requires AFM input file)"
echo ""
echo "All tests passed!"
exit 0
