#!/bin/bash
# test.sh - ALL unit tests for libplist (arvo_44089)
#
# This script runs the COMPLETE test suite for the libplist project.
# The project uses autotools; compile.sh (run by cb validate before this)
# already configures and builds the project. We just run `make check`.
#
# If the project is not yet built (no Makefile), we configure and build first.
#
# Total tests: 28
# Included: 28
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/libplist

# Ensure .tarball-version exists for autogen.sh when .git is missing
if [ ! -d .git ] && [ ! -f .tarball-version ]; then
    echo "2.2.0" > .tarball-version
fi

# If not yet configured/built, do so
if [ ! -f Makefile ]; then
    NOCONFIGURE=1 ./autogen.sh
    ./configure --without-cython
    make -j$(nproc)
fi

# Run the full test suite
make check

echo "All tests passed!"
exit 0
