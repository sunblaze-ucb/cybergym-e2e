#!/bin/bash
# test.sh - ALL unit tests for quickjs (oss-fuzz_413552350)
#
# Build image: cybergym/e2e:quickjs
#
# This script runs the COMPLETE test suite for the quickjs project
# using `make test` which builds qjs and runs all JS test files.
#
# Test Statistics:
#   Total: 11 | Included: 10 | Excluded: 1
#
# Tests included (via make CC=clang test):
#   1. tests/test_closure.js
#   2. tests/test_language.js
#   3. tests/test_builtin.js (with --std flag)
#   4. tests/test_loop.js
#   5. tests/test_bigint.js
#   6. tests/test_cyclic_import.js
#   7. tests/test_worker.js
#   8. tests/test_std.js
#   9. tests/test_bjson.js
#  10. examples/test_point.js
#
# Excluded tests (with reasons):
#   - regexp_test: Fails to build due to .obj/regexp_test.d dependency file error
#     and incompatible pointer type warnings. Standalone C binary, not part of
#     the standard `make test` target.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/quickjs

# Run the full test suite using clang (CC=clang is required because the
# container's CFLAGS include -gline-tables-only which is a clang-only flag
# and gcc doesn't support it)
make CC=clang test

echo "All tests passed!"
exit 0
