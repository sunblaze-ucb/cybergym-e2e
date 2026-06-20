#!/usr/bin/env bash
set -euo pipefail

# Move to the ArduinoJson source inside the container (default SRC=/src)
cd "${SRC:-/src}/arduinojson"

echo "=== Running unit tests for ArduinoJson ==="

# Use a clean set of flags for tests to avoid inheriting fuzzer/libc++ flags from the build stage
# and disable Catch2's POSIX signal handler that trips altstack issues on this toolchain.
unset CFLAGS CXXFLAGS CPPFLAGS LDFLAGS || true
export CFLAGS="-O0 -g -DCATCH_CONFIG_NO_POSIX_SIGNALS"
export CXXFLAGS="-O0 -g -DCATCH_CONFIG_NO_POSIX_SIGNALS -Wno-error=c++11-extensions"

# Verify required tools
if ! command -v cmake >/dev/null 2>&1; then
    echo "✗ cmake not found in PATH"
    exit 1
fi
if ! command -v ctest >/dev/null 2>&1; then
    echo "✗ ctest not found in PATH"
    exit 1
fi

# Configure and build (match upstream CI behavior; in-source build)
echo "-- Configuring (Debug)"
cmake \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_CXX_STANDARD=11 \
    -DCMAKE_CXX_STANDARD_REQUIRED=ON \
    -DCMAKE_CXX_EXTENSIONS=OFF \
    .

echo "-- Building"
if command -v nproc >/dev/null 2>&1; then
    cmake --build . -j"$(nproc)"
else
    cmake --build .
fi

# Run tests via CTest with optional regex filter (TEST_REGEX)
echo "-- Running tests"
# Exclude MemorySanitizer-based fuzzers which are unreliable in this environment
CTEST_ARGS=("--output-on-failure" "-E" "memory_fuzzer")
if [[ -n "${TEST_REGEX:-}" ]]; then
    CTEST_ARGS=("-R" "${TEST_REGEX}" "--output-on-failure")
fi

ctest "${CTEST_ARGS[@]}" .

echo "✓ Tests completed"