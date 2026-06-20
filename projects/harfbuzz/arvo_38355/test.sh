#!/bin/bash
# test.sh - ALL unit tests for harfbuzz (arvo_38355)
#
# This script runs the COMPLETE test suite for the harfbuzz project.
# Build system: meson
#
# Test Statistics:
#   Total: 21 | Included: 21 | Excluded: 0
#
# Test Categories:
#   - src tests (12): test-algs, test-array, test-repacker, test-priority-queue,
#                     test-iter, test-map, test-number, test-ot-tag, test-set,
#                     test-unicode-ranges, test-vector, test-bimap
#   - src checks (6): check-c-linkage-decls, check-externs, check-header-guards,
#                     check-includes, check-static-inits, check-symbols
#   - fuzzing tests (3): shape_fuzzer, subset_fuzzer, draw_fuzzer
#
# Note: API tests (test/api/) require glib which is not available in this build.
#       Shape and subset tests require hb-shape/hb-subset tools built with
#       specific dependencies that are not present.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/harfbuzz

# Build if needed (meson setup is idempotent)
if [ ! -d "build" ]; then
    meson setup build
fi

# Build the project
ninja -C build

# Run the complete test suite
meson test -C build

echo "All tests passed!"
exit 0
