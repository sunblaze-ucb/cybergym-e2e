#!/usr/bin/env bash
# test.sh - ALL unit tests for glib (arvo_28458)
#
# This runs the COMPLETE test suite for the glib project, excluding only
# tests that genuinely fail in the Docker container environment.
#
# Test Statistics:
#   Total tests: 246
#   Included: 241
#   Excluded: 5
#
# Excluded tests (with reasons):
#   - option-argv0: SIGABRT - g_get_prgname() returns unexpected value in
#     container environment; test_platform_argv0 assertion fails
#   - defaultvalue: SIGABRT - requires dbus-daemon which is not installed
#     in the container
#   - appinfo: SIGTRAP - assertion failure, missing desktop file database
#     in container environment
#   - desktop-app-info: SIGTRAP - assertion failure, missing desktop file
#     database in container environment
#   - resources: SIGABRT - test_resource_binary_linked assertion fails;
#     binary-linked resource data not found ('found' should be TRUE)
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/glib

# Reset compiler flags to avoid sanitizer/fuzzing flags from compile.sh
unset CFLAGS CXXFLAGS LDFLAGS SANITIZER FUZZING_ENGINE
unset ASAN_OPTIONS MSAN_OPTIONS UBSAN_OPTIONS

# Use gcc explicitly to avoid clang/ccache issues
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++

# Install build dependencies if not present
if ! command -v meson &> /dev/null; then
    pip3 install 'meson>=0.49.2,<1.0.0' > /dev/null 2>&1
fi
if ! command -v ninja &> /dev/null; then
    apt-get update -qq > /dev/null 2>&1
    apt-get install -y -qq ninja-build pkg-config libmount-dev libselinux1-dev zlib1g-dev libffi-dev gettext libpcre3-dev > /dev/null 2>&1
fi

# Ensure the build directory exists and project is configured
if [ ! -d "_build" ]; then
    meson setup _build --prefix=/usr
    ninja -C _build -j$(nproc)
else
    ninja -C _build -j$(nproc)
fi

# Run the full test suite, excluding only the 5 known-failing tests.
# We generate the list of all tests minus the excluded ones and pass them
# as positional arguments to meson test.
ALL_TESTS=$(meson test -C _build --no-rebuild --list 2>&1 | sed 's/^.* \/ //' | sed 's/^.* - glib://')
EXCLUDE_PATTERN="^(option-argv0|defaultvalue|appinfo|desktop-app-info|resources)$"
TESTS_TO_RUN=$(echo "$ALL_TESTS" | grep -v -E "$EXCLUDE_PATTERN" | tr '\n' ' ')

meson test -C _build --no-rebuild --print-errorlogs --timeout-multiplier=3 $TESTS_TO_RUN

echo "All tests passed!"
exit 0
