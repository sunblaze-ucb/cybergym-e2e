#!/bin/bash
# test.sh - ALL unit tests for quickjs (oss-fuzz_428754593)
#
# Build image: cybergym/e2e:quickjs
#
# Test Statistics:
#   Total: 10 | Included: 10 | Excluded: 0
#
# Tests run (via `make test`):
#   1. test_closure.js
#   2. test_language.js
#   3. test_builtin.js (--std)
#   4. test_loop.js
#   5. test_bigint.js
#   6. test_cyclic_import.js
#   7. test_worker.js
#   8. test_std.js
#   9. test_bjson.js
#  10. test_point.js (examples)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/quickjs

# Unset fuzzer-related CFLAGS that are incompatible with gcc
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS

# Clean any objects built with wrong flags
make clean 2>/dev/null || true

# Build qjs and test dependencies
make qjs tests/bjson.so examples/point.so

# Run the full test suite
make test

echo "All tests passed!"
exit 0
