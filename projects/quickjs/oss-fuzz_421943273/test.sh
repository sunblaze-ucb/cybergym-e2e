#!/bin/bash
# test.sh - ALL unit tests for quickjs (oss-fuzz_421943273)
#
# Build image: cybergym/e2e:quickjs
#
# Test Statistics:
#   Total: 11 | Included: 10 | Excluded: 1
#
# Included tests (via `make test`):
#   1. test_closure.js
#   2. test_language.js
#   3. test_builtin.js (--std)
#   4. test_loop.js
#   5. test_bigint.js
#   6. test_cyclic_import.js
#   7. test_worker.js
#   8. test_std.js
#   9. test_bjson.js (requires bjson.so shared lib)
#  10. test_point.js (requires point.so shared lib)
#
# Excluded tests (with reasons):
#   - regexp_test: Fails to build due to dependency file path error
#     (.obj/regexp_test.d: No such file or directory) and incompatible
#     pointer type warnings/errors in the vulnerable code. Cannot fix
#     source code per project rules.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/quickjs

# Build quickjs with clang (required by the oss-fuzz container environment
# which sets CC=clang and CFLAGS with clang-specific flags)
make -j$(nproc) CONFIG_CLANG=y

# Run the full test suite (10 tests)
make test CONFIG_CLANG=y

echo "All tests passed!"
exit 0
