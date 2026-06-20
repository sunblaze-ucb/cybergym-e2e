#!/bin/bash
# test.sh - ALL unit tests for libplist (arvo_44695)
#
# This script runs the COMPLETE test suite for the libplist project.
# The project uses autotools and "make check" runs all 29 tests.
#
# Test Statistics:
#   Total tests: 29
#   Included: 29
#   Excluded: 0
#
# All tests:
#   empty.test, small.test, medium.test, large.test, huge.test,
#   bigarray.test, dates.test, timezone1.test, timezone2.test,
#   signedunsigned1.test, signedunsigned2.test, signedunsigned3.test,
#   hex.test, order.test, recursion.test, entities.test,
#   empty_keys.test, amp.test, invalid_tag.test, cdata.test,
#   offsetsize.test, refsize.test, malformed_dict.test, uid.test,
#   json1.test, json2.test, json3.test, json-invalid-types.test,
#   json-int64-min-max.test
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/libplist

# Build the project if not already built
if [ ! -f Makefile ]; then
    ./autogen.sh --without-cython --enable-debug
    make -j$(nproc) all
fi

# Run the full test suite
make check

echo "All tests passed!"
exit 0
