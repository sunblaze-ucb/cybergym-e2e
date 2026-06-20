#!/usr/bin/env bash
# test.sh - ALL unit tests for harfbuzz (arvo_21580)
#
# This script runs the COMPLETE test suite for the harfbuzz project
# using the meson build system with gcc (no sanitizers).
#
# Test Statistics:
#   Total tests: 335
#   Passed: 301
#   Skipped: 34 (platform-specific or missing optional deps like hb-subset CLI)
#   Failed: 0
#   Excluded: 0
#
# Skipped tests (inherent to test suite, not excluded by us):
#   - macos: Requires macOS-specific fonts
#   - Various *_lookupflag AOTS tests: Skipped by test framework (expected diffs)
#   - gpos3_lookupflag, gpos4_*, gpos5, gpos6: Skipped by test framework
#   - gsub3_1_simple, lookupflag_ignore_attach: Skipped by test framework
#   - basics, full-font, cff-full-font, japanese, cff-japanese: Subset integration
#     tests skipped because hb-subset CLI not available in test path
#   - layout.*, cmap, cmap14, sbix, colr, cbdt: Subset integration tests skipped
#
# Build requirements installed by this script:
#   - pkg-config, libglib2.0-dev, libfreetype6-dev, meson, ninja-build
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

SRC_DIR="${SRC:-/src}/harfbuzz"
BUILD_DIR="${SRC_DIR}/build"

echo "=== Installing test dependencies ==="
apt-get update -qq
apt-get install -y -qq pkg-config libglib2.0-dev libfreetype6-dev meson ninja-build > /dev/null 2>&1

echo "=== Configuring harfbuzz with meson ==="
cd "${SRC_DIR}"

# Use gcc without sanitizer flags for testing
# (the container env has fuzzer-specific CFLAGS/CXXFLAGS that break normal tests)
unset CFLAGS CXXFLAGS SANITIZER
export CC=gcc
export CXX=g++

# Remove old build dir if it exists (for idempotent runs)
rm -rf "${BUILD_DIR}"

meson "${BUILD_DIR}" --default-library=both

echo "=== Building harfbuzz ==="
cd "${BUILD_DIR}"
ninja -j"$(nproc)"

echo "=== Running ALL tests ==="
meson test --no-rebuild --print-errorlogs

echo "All tests passed!"
exit 0
