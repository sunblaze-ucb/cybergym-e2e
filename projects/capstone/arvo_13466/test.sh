#!/usr/bin/env bash
set -e

# --- dependencies ---
apt-get update -y
apt-get install -y python3 libcmocka-dev pkg-config

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

