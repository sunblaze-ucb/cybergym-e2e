#!/bin/bash
# test.sh - ALL unit tests for freetype2 (arvo_8968)
#
# FreeType2 v2.9.1 does not have a formal test suite (no `make check`,
# `ctest`, or `meson test`). The available test programs are located in
# src/tools/ and are standalone C files compiled against the library.
#
# This script uses the library already built by compile.sh (via autotools).
# The static library is at objs/.libs/libfreetype.a
# Since compile.sh builds with ASan instrumentation, test programs must
# also be compiled with matching sanitizer flags.
#
# Included tests:
#   1. FreeType API test - Verifies FT_Init_FreeType, FT_Library_Version,
#      and FT_Done_FreeType work correctly (based on builds/cmake/testbuild.sh)
#   2. test_bbox (src/tools/test_bbox.c) - Tests FT_Outline_Get_BBox and
#      FT_Outline_Get_CBox with predefined outline data (3 outlines)
#   3. test_trig (src/tools/test_trig.c) - Tests trigonometry functions:
#      cos, sin, tan, atan2, unit vector, length, rotate
#
# Excluded tests:
#   - test_afm (src/tools/test_afm.c): Requires an AFM font file as
#     command-line argument; no test font files are available in the container
#
# Note on test_trig: The test has a bug where main() returns `!error`
# instead of `error`, so it returns exit code 1 even on success.
# We check for the "trigonometry test ok" output string instead.
#
# Total tests discovered: 4
# Included: 3
# Excluded: 1 (test_afm - requires input file not available)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

SRCDIR=${SRC:-/src}/freetype2
cd "$SRCDIR"

# Locate the built library (from compile.sh autotools build)
if [ -f objs/.libs/libfreetype.a ]; then
    LIBDIR="objs/.libs"
elif [ -f objs/libfreetype.a ]; then
    LIBDIR="objs"
else
    echo "ERROR: libfreetype.a not found. compile.sh must run first."
    exit 1
fi

# Use clang with sanitizer flags to match the library built by compile.sh
# The compile step builds with ASan, so test binaries need matching flags.
TEST_CC="${CC:-clang}"
TEST_CFLAGS="-fsanitize=address -fsanitize-address-use-after-scope -fsanitize=fuzzer-no-link -Wno-implicit-function-declaration -Wno-implicit-int -Wno-format"

# Disable leak detection for tests (not relevant, avoids false positives)
export ASAN_OPTIONS="${ASAN_OPTIONS:+$ASAN_OPTIONS:}detect_leaks=0"

PASS=0
FAIL=0

echo "=== FreeType2 Test Suite ==="
echo "Using library: $SRCDIR/$LIBDIR/libfreetype.a"

########################################################################
# Test 1: FreeType API test (init, version, cleanup)
########################################################################
echo ""
echo "--- Test 1: FreeType API test (init, version, cleanup) ---"

cat > /tmp/test_ft_api.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <ft2build.h>
#include FT_FREETYPE_H

FT_Library library;

int main(void)
{
  FT_Error error;
  FT_Int major = 0;
  FT_Int minor = 0;
  FT_Int patch = 0;

  error = FT_Init_FreeType(&library);
  if (error) {
    printf("FAIL: FT_Init_FreeType returned error %d\n", error);
    return EXIT_FAILURE;
  }

  FT_Library_Version(library, &major, &minor, &patch);
  if (major != FREETYPE_MAJOR
      || minor != FREETYPE_MINOR
      || patch != FREETYPE_PATCH) {
    printf("FAIL: Version mismatch: lib=%d.%d.%d header=%d.%d.%d\n",
           major, minor, patch, FREETYPE_MAJOR, FREETYPE_MINOR, FREETYPE_PATCH);
    return EXIT_FAILURE;
  }

  printf("FT_Library_Version: %d.%d.%d\n", major, minor, patch);

  error = FT_Done_FreeType(library);
  if (error) {
    printf("FAIL: FT_Done_FreeType returned error %d\n", error);
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
EOF

$TEST_CC $TEST_CFLAGS -I./include -I. \
   /tmp/test_ft_api.c \
   -o /tmp/test_ft_api \
   "$LIBDIR/libfreetype.a" -lm 2>/dev/null

/tmp/test_ft_api
echo "PASS: FreeType API test"
PASS=$((PASS + 1))

########################################################################
# Test 2: test_bbox (bounding box computation test)
########################################################################
echo ""
echo "--- Test 2: test_bbox (bounding box computation) ---"

$TEST_CC $TEST_CFLAGS -DFT2_BUILD_LIBRARY -I./include -I. \
   ./src/tools/test_bbox.c \
   -o /tmp/test_bbox \
   "$LIBDIR/libfreetype.a" -lm 2>/dev/null

/tmp/test_bbox
echo "PASS: test_bbox"
PASS=$((PASS + 1))

########################################################################
# Test 3: test_trig (trigonometry functions test)
########################################################################
echo ""
echo "--- Test 3: test_trig (trigonometry functions) ---"

$TEST_CC $TEST_CFLAGS -DFT2_BUILD_LIBRARY -I./include -I. \
   ./src/tools/test_trig.c \
   -o /tmp/test_trig \
   "$LIBDIR/libfreetype.a" -lm 2>/dev/null

# test_trig has a bug: returns !error (exit 1 on success), so check output
TRIG_OUTPUT=$(/tmp/test_trig 2>&1 || true)
if echo "$TRIG_OUTPUT" | grep -q "trigonometry test ok"; then
    echo "PASS: test_trig"
    PASS=$((PASS + 1))
else
    echo "FAIL: test_trig"
    echo "$TRIG_OUTPUT"
    FAIL=$((FAIL + 1))
fi

########################################################################
# Cleanup
########################################################################
rm -f /tmp/test_ft_api /tmp/test_ft_api.c /tmp/test_bbox /tmp/test_trig

########################################################################
# Summary
########################################################################
echo ""
echo "=== Test Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Total:  $((PASS + FAIL))"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi

echo "All tests passed!"
exit 0
