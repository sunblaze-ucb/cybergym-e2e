#!/bin/bash
# test.sh - ALL unit tests for quickjs (oss-fuzz_416299802)
#
# Build image: cybergym/e2e:quickjs
#
# Test Statistics:
#   Total: 11 | Included: 10 | Excluded: 1
#
# Included tests (via `make test CONFIG_CLANG=y`):
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
# Excluded tests (with reasons):
#   - regexp_test: Fails to compile due to incompatible pointer types and
#     missing .obj/regexp_test.d dependency file. Build error in source code.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/quickjs

# Build qjs and test dependencies, then run the full test suite
# CONFIG_CLANG=y is needed because the env CFLAGS contain clang-specific flags
# (e.g. -gline-tables-only) that are incompatible with gcc
make test CONFIG_CLANG=y

echo "All tests passed!"
exit 0
