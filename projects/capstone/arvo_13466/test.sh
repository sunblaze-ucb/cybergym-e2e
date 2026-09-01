#!/usr/bin/env bash
set -e

# --- dependencies ---
true  # apt lists fetched in prepare.sh
cp -n /deps/debs/*.deb /var/cache/apt/archives/ 2>/dev/null || true; apt-get install -y --no-download python3 libcmocka-dev pkg-config  # pre-downloaded in prepare.sh

# --- build Capstone and tests ---
cd "$SRC/capstonenext"

rm -rf build
mkdir build
cd build

# Build in Debug mode, enable cstest
cmake .. \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCAPSTONE_BUILD_CSTEST=ON \
  -DCAPSTONE_BUILD_TESTS=ON

cmake --build . --config Debug

# --- run the tests ---
ctest --output-on-failure
# (or to run only the regression tests)
# ctest -R cstest --output-on-failure

