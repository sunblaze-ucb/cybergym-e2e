#!/bin/bash
# test.sh - ALL unit tests for harfbuzz (oss-fuzz_433311403)
#
# Build image: cybergym/e2e:harfbuzz
# Build system: meson + ninja
#
# This runs the full test suite from /work/build (set up by compile.sh).
# compile.sh builds harfbuzz with clang + ASAN into /work/build but only
# builds fuzzer targets. We run ninja to also build test binaries.
#
# Test Statistics:
#   Total: 59 | Included: 28 | Excluded: 1 | Skipped by meson: 30
#
# Excluded tests (with reasons):
#   - check-includes: Fails (exit status 1) because ASAN build flags cause
#     the include-check script to fail on sanitizer-related flags
#
# Skipped by meson (not our exclusion - fuzzer binaries auto-skip under ASAN):
#   - 30 fuzzer chunk tests (shape/draw/subset/repacker/set fuzzer chunks)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /work/build

# Build all targets including test binaries
ninja -j$(nproc)

# Run all tests except fuzzing suite (auto-skips under ASAN anyway) and
# check-includes (fails under ASAN build flags).
# We list tests explicitly to exclude check-includes.
meson test --no-rebuild --print-errorlogs --no-suite fuzzing \
  test-algs test-array test-bimap test-cff test-classdef-graph test-decycler \
  test-iter test-machinery test-map test-multimap test-number test-ot-tag \
  test-set test-serialize test-vector test-repacker test-instancer-solver \
  test-priority-queue test-tuple-varstore test-item-varstore test-unicode-ranges \
  check-c-linkage-decls check-externs check-header-guards \
  check-static-inits check-symbols check-libstdc++ \
  check-release-notes \
  shape_threads subset_threads

echo "All tests passed!"
exit 0
