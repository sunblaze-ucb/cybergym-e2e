#!/usr/bin/env bash
# test.sh - ALL unit tests for quickjs (oss-fuzz_410939009)
#
# Build image: cybergym/e2e:quickjs
#
# Test Statistics:
#   Total: 11 | Included: 10 | Excluded: 1
#
# Excluded tests (with reasons):
#   - regexp_test: Fails to build due to incompatible pointer types in
#     lre_exec call and missing dependency file. Pre-existing code issue.
#
# Included tests (run via `make CONFIG_CLANG=y test`):
#   1. tests/test_closure.js
#   2. tests/test_language.js
#   3. tests/test_builtin.js (--std)
#   4. tests/test_loop.js
#   5. tests/test_bigint.js
#   6. tests/test_cyclic_import.js
#   7. tests/test_worker.js
#   8. tests/test_std.js
#   9. tests/test_bjson.js
#  10. examples/test_point.js
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/quickjs

# Clean any prior build artifacts
make clean 2>/dev/null || true

# Build and run the full test suite.
# CONFIG_CLANG=y is needed because the container has CC=clang with
# clang-specific CFLAGS, but the Makefile defaults to gcc on Linux.
make CONFIG_CLANG=y test

echo "All tests passed!"
exit 0

