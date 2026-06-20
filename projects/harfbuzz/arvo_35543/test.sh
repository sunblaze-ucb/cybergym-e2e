#!/bin/bash
# test.sh - ALL unit tests for harfbuzz (arvo_35543)
#
# Build image: gcr.io/oss-fuzz-base/base-builder@sha256:fba1033c6a64433642ab97b6ea987ddaa9938e06596c6cace1c786130fc1461b
#
# This runs the COMPLETE test suite for the harfbuzz project using meson.
#
# Test Statistics:
#   Total tests: 20
#   Included: 20
#   Excluded: 0
#
# Tests included:
#   harfbuzz:src / test-algs
#   harfbuzz:src / test-array
#   harfbuzz:src / test-repacker
#   harfbuzz:src / test-priority-queue
#   harfbuzz:src / test-iter
#   harfbuzz:src / test-meta
#   harfbuzz:src / test-number
#   harfbuzz:src / test-ot-tag
#   harfbuzz:src / test-unicode-ranges
#   harfbuzz:src / test-bimap
#   harfbuzz:src / check-c-linkage-decls
#   harfbuzz:src / check-externs
#   harfbuzz:src / check-header-guards
#   harfbuzz:src / check-includes
#   harfbuzz:src / check-libstdc++
#   harfbuzz:src / check-static-inits
#   harfbuzz:src / check-symbols
#   harfbuzz:fuzzing+slow / shape_fuzzer
#   harfbuzz:fuzzing+slow / subset_fuzzer
#   harfbuzz:fuzzing / draw_fuzzer
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/harfbuzz

# Setup the meson build directory if it does not already exist
if [ ! -d build ]; then
    meson setup build
fi

# Build all targets
ninja -C build

# Run the full test suite
meson test -C build --print-errorlogs

echo "All tests passed!"
exit 0
