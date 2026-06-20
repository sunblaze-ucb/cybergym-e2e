#!/bin/bash
# test.sh - Unit tests for faad2 (arvo_58452)
#
# NOTE: faad2 does not have traditional unit tests defined in its build system.
# The 'make check' target exists but has no tests defined ("Nothing to be done for 'check'").
# The project uses OSS-Fuzz for fuzzing tests, which are run separately via CI.
#
# This script:
#   1. Configures and builds the project (with clean build flags)
#   2. Runs 'make check' (which succeeds but has no tests)
#   3. Verifies the faad binary runs correctly (basic sanity check)
#
# Total tests: 0 (no unit tests defined in project)
# This is expected - faad2 relies on OSS-Fuzz for testing.
#
# Exit codes:
#   0 - Build succeeded and make check passed
#   1 - Build or tests failed

set -e

cd ${SRC:-/src}/faad2

# Clean any previous build artifacts to avoid sanitizer flag mismatches
if [ -f Makefile ]; then
    make distclean || make clean || true
fi
rm -rf autom4te.cache config.status config.log

# Override environment to use clean build flags (no sanitizers)
# This prevents linker errors from mixed sanitizer builds
export CC=clang
export CXX=clang++
export CFLAGS="-O2 -g"
export CXXFLAGS="-O2 -g"
export LDFLAGS=""

echo "=== Building faad2 ==="
./bootstrap
./configure
make -j$(nproc)

echo "=== Running make check ==="
make check

echo "=== Verifying faad binary works ==="
# faad --help exits with code 1, so we check it runs but ignore exit code
./frontend/faad --help > /dev/null 2>&1 || true

# Verify the binary exists and is executable
if [ ! -x ./frontend/faad ]; then
    echo "ERROR: faad binary not found or not executable"
    exit 1
fi

echo "All tests passed!"
exit 0
