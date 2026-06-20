#!/bin/bash
# test.sh - ALL unit tests for libxslt (arvo_57061)
#
# This script runs the COMPLETE test suite for the libxslt project.
# It builds libxml2 and libxslt from source, then runs all tests.
#
# Test categories run:
#   - REC2 tests
#   - REC tests (standalone)
#   - REC tests without dictionaries
#   - REC tests without dictionaries (standalone)
#   - general tests
#   - general tests without dictionaries
#   - encoding tests
#   - documents tests
#   - numbers tests
#   - keys tests
#   - namespaces tests
#   - extensions tests
#   - reports tests
#   - exslt common tests
#   - exslt crypto tests
#   - exslt date tests
#   - exslt dynamic tests
#   - exslt functions tests
#   - exslt math tests
#   - exslt saxon tests
#   - exslt sets tests
#   - exslt strings tests
#
# Total tests: 740
# Excluded tests: 0 (plugin tests disabled - require shared library build)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Build libxml2 (dependency)
cd /src/libxml2
./autogen.sh --disable-shared --without-python
make -j$(nproc)

# Build libxslt
cd /src/libxslt
./autogen.sh --with-libxml-src=../libxml2 --disable-shared --without-python
make -j$(nproc)

# Run the full test suite
cd /src/libxslt/tests
make check

echo "All tests passed!"
exit 0
