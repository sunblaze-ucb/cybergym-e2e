#!/bin/bash
# test.sh - ALL unit tests for libjxl (oss-fuzz_454749502)
#
# Build image: cybergym/e2e:libjxl
#
# Test Statistics:
#   Total: 8169 | Included: 8167 | Excluded: 2
#
# Excluded tests (with reasons):
#   - GaussBlurTest.SlowTestDirac1D: Disabled by upstream (marked DISABLED_ in source)
#   - bash_test: Source code linting test that requires clean git state; fails after
#     src.tgz extraction because git submodule .git files point to non-existent paths
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/libjxl

# Submodules are populated from src.tgz but .git files may point to invalid paths.
# Remove invalid .git files so CMake doesn't get confused.
for d in testdata third_party/googletest third_party/lcms third_party/sjpeg \
         third_party/libpng third_party/zlib third_party/highway third_party/brotli \
         third_party/skcms third_party/libjpeg-turbo; do
  if [ -f "$d/.git" ]; then
    rm -f "$d/.git"
  fi
done

# Install libpng-dev needed by tests
apt-get update -qq && apt-get install -y -qq libpng-dev zlib1g-dev > /dev/null 2>&1

# Configure build for testing (not fuzzing)
unset FUZZING_ENGINE SANITIZER
export CC=clang CXX=clang++
export CFLAGS='-O1'
export CXXFLAGS='-O1 -stdlib=libc++'
export LDFLAGS='-stdlib=libc++'

mkdir -p /tmp/build && cd /tmp/build
cmake /src/libjxl \
  -DBUILD_TESTING=ON \
  -DJPEGXL_ENABLE_FUZZERS=OFF \
  -DJPEGXL_ENABLE_BENCHMARK=OFF \
  -DJPEGXL_ENABLE_TOOLS=OFF \
  -DJPEGXL_ENABLE_MANPAGES=OFF \
  -DJPEGXL_ENABLE_PLUGINS=OFF \
  -DJPEGXL_FORCE_SYSTEM_GTEST=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  > /dev/null 2>&1

# Build all test targets
cmake --build . -j$(nproc) > /dev/null 2>&1

# Run the full test suite
# Exclude bash_test (source linting requiring clean git) and disabled GaussBlurTest
ctest --output-on-failure -j$(nproc) --timeout 60 -E "bash_test"

echo "All tests passed!"
exit 0
