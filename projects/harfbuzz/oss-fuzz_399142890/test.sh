#!/bin/bash
# test.sh - ALL unit tests for harfbuzz
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
true  # apt lists fetched in prepare.sh
cp -n /deps/debs/*.deb /var/cache/apt/archives/ 2>/dev/null || true; apt-get install -y --no-download libglib2.0-dev libfreetype6-dev libicu-dev pkg-config  # pre-downloaded in prepare.sh
pip3 install --no-index --find-links=/deps/wheels meson ninja  # pre-downloaded in prepare.sh

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
