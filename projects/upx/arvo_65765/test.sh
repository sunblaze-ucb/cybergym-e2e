#!/usr/bin/env bash
set -e

cd /src/upx

echo "Configuring build..."
rm -rf build/release

# Use -U__clang_major__ -D__clang_major__=14 to work around clang 15 ICE
# (Internal Compiler Error) in memswap_no_overlap() function
cmake -S . -B build/release -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-U__clang_major__ -D__clang_major__=14" \
  -DCMAKE_EXE_LINKER_FLAGS="-lpthread" \
  >/dev/null 2>&1

echo "Building upx..."
cmake --build build/release --target upx --parallel >/dev/null 2>&1

echo "Running tests..."
cd build/release
if ctest --output-on-failure; then
  echo "============================================="
  echo "All tests passed!"
else
  echo "============================================="
  echo "Some tests failed!"
  exit 1
fi
