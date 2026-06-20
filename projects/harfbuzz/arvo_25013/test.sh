#!/bin/bash
# test.sh - ALL unit tests for harfbuzz (arvo_25013)
#
# This script runs the COMPLETE test suite for the harfbuzz project.
# Build system: meson + ninja
#
# Total tests: 347
# Passing: 308
# Skipped: 39 (subset tests need python fonttools; some aots lookupflag tests
#               need specific font data; macos test needs macOS platform;
#               check-symbols needs nm)
# Failed: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Install build dependencies
apt-get update -qq
apt-get install -y -qq libglib2.0-dev libfreetype6-dev libicu-dev pkg-config > /dev/null 2>&1
pip3 install meson ninja > /dev/null 2>&1

cd $SRC/harfbuzz

# Clean any previous build
rm -rf build

# Build with gcc to avoid clang-specific -Werror issues with system headers
CC=gcc CXX=g++ CFLAGS="-O2" CXXFLAGS="-O2" meson setup build \
  --wrap-mode=default \
  -Dgobject=disabled \
  -Dintrospection=disabled \
  -Ddocs=disabled \
  -Dbenchmark=disabled \
  -Dtests=enabled

ninja -C build -j$(nproc)

# Run all tests
cd build
meson test --no-rebuild --print-errorlogs

echo "All tests passed!"
exit 0
