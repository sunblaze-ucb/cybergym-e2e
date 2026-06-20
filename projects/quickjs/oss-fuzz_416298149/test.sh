#!/usr/bin/env bash
# test.sh - ALL unit tests for quickjs (oss-fuzz_416298149)
#
# Build image: cybergym/e2e:quickjs
#
# Runs the full "make test" target from the QuickJS Makefile.
# This builds qjs, bjson.so, point.so and runs all 10 test scripts.
#
# Test Statistics:
#   Total: 10 | Included: 10 | Excluded: 0
#
# Tests included (from Makefile "test" target):
#   1. tests/test_closure.js       - Closure tests
#   2. tests/test_language.js      - Language feature tests
#   3. tests/test_builtin.js       - Built-in object tests (--std mode)
#   4. tests/test_loop.js          - Loop tests
#   5. tests/test_bigint.js        - BigInt tests
#   6. tests/test_cyclic_import.js - Cyclic import tests
#   7. tests/test_worker.js        - Worker tests
#   8. tests/test_std.js           - Standard library tests
#   9. tests/test_bjson.js         - Binary JSON tests (requires bjson.so)
#  10. examples/test_point.js      - Point example test (requires point.so)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/quickjs

# The container has CC=clang in the environment but the Makefile defaults
# to gcc unless CONFIG_CLANG is set. Use CONFIG_CLANG=y to pick up clang
# which supports the -gline-tables-only flag set in CFLAGS.
make CONFIG_CLANG=y test 2>&1

echo "All tests passed!"
exit 0
