#!/bin/bash
# test.sh - ALL unit tests for libphonenumber (oss-fuzz_413161357)
#
# Build image: cybergym/e2e:libphonenumber
#
# Test Statistics:
#   Total: 304 | Included: 304 | Excluded: 0
#
# Test suites (12):
#   - AsYouTypeFormatterTest
#   - LoggerTest
#   - MatcherTest
#   - PhoneNumberUtilTest
#   - RegExpAdapterTest
#   - RegExpCacheTest
#   - ShortNumberInfoTest
#   - StringUtilTest
#   - UnicodeStringTest
#   - UnicodeTextTest
#   - PhoneNumberMatchTest
#   - PhoneNumberMatcherTest
#
# The compile.sh builds libphonenumber with BUILD_TESTING=OFF, so we need
# to rebuild with BUILD_TESTING=ON to get the test binary.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/libphonenumber/cpp

# Build tests in a separate build directory
mkdir -p build-test && cd build-test

export CC=clang
export CXX=clang++

cmake -DUSE_BOOST=OFF -DBUILD_GEOCODER=OFF \
      -DBUILD_STATIC_LIB=ON -DBUILD_SHARED_LIBS=OFF \
      -DBUILD_TESTING=ON \
      -DCMAKE_CXX_FLAGS='-stdlib=libc++ -std=c++17 -Wno-error -fsanitize=address -fsanitize-coverage=trace-pc-guard,indirect-calls,trace-cmp' \
      -DCMAKE_C_FLAGS='-Wno-error -fsanitize=address -fsanitize-coverage=trace-pc-guard,indirect-calls,trace-cmp' \
      -DCMAKE_EXE_LINKER_FLAGS='-fsanitize=address' \
      -DICU_UC_INCLUDE_DIR=/src/icu/source/common \
      -DICU_UC_LIB=/src/deps/lib/libicuuc.a \
      -DICU_I18N_INCLUDE_DIR=/src/icu/source/i18n/ \
      -DICU_I18N_LIB=/src/deps/lib/libicui18n.a \
      -DREGENERATE_METADATA=ON \
      ../ > /dev/null 2>&1

make -j$(nproc) libphonenumber_test > /dev/null 2>&1

# Run all 304 tests with leak detection disabled (ASan leak detector
# can produce false positives in this environment)
ASAN_OPTIONS=detect_leaks=0 ./libphonenumber_test

echo "All tests passed!"
exit 0
