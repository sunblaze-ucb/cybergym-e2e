#!/bin/bash
# test.sh - ALL unit tests for freetype2 (arvo_8933)
#
# Freetype2 v2.9.1 (2018 era) has limited built-in tests in its source tree.
# This script runs ALL available tests:
#
# 1. test_bbox   - Bounding box computation test (src/tools/test_bbox.c)
# 2. test_trig   - Trigonometry functions test (src/tools/test_trig.c)
# 3. cmake testbuild - Builds freetype, creates test app, verifies FT_Library_Version
#
# Excluded tests (with reasons):
#   - test_afm (src/tools/test_afm.c): Requires an AFM font file as input argument;
#     no AFM files are available in the container. Cannot run without test data.
#
# Total tests discovered: 4
# Included: 3
# Excluded: 1
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/freetype2

echo "=== Building freetype2 library (if not already built) ==="
if [ ! -f build/libfreetyped.a ]; then
    mkdir -p build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Debug
    cmake --build . -j$(nproc)
    cd /src/freetype2
fi

echo ""
echo "=== Test 1/3: test_bbox (bounding box computation) ==="
gcc -DFT2_BUILD_LIBRARY -I./include -o /tmp/test_bbox src/tools/test_bbox.c -L./build -lfreetyped -lm
/tmp/test_bbox
echo "PASSED: test_bbox"

echo ""
echo "=== Test 2/3: test_trig (trigonometry functions) ==="
gcc -DFT2_BUILD_LIBRARY -I./include -o /tmp/test_trig src/tools/test_trig.c -L./build -lfreetyped -lm
# Note: test_trig uses "return !error" which returns exit code 1 on success
# (C convention: !0 = 1 = true = no error). The test prints
# "trigonometry test ok !" when all sub-tests pass.
# We check for the success message in the output instead of exit code.
set +e
TRIG_OUTPUT=$(/tmp/test_trig 2>&1)
set -e
echo "$TRIG_OUTPUT"
if echo "$TRIG_OUTPUT" | grep -q "trigonometry test ok"; then
    echo "PASSED: test_trig"
else
    echo "FAILED: test_trig"
    exit 1
fi

echo ""
echo "=== Test 3/3: cmake testbuild (build and version check) ==="
# Clean up any previous testbuild artifacts
rm -rf /tmp/freetype-cmake-testbuild

# Run the official cmake testbuild script
bash builds/cmake/testbuild.sh

# Clean up testbuild artifacts
rm -rf /tmp/freetype-cmake-testbuild

echo "PASSED: cmake testbuild"

echo ""
echo "All tests passed!"
exit 0
