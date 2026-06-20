#!/usr/bin/env bash
# test.sh - Unit tests for binutils (arvo_18228)
#
# This container is a minimal OSS-Fuzz build environment. The build is
# intentionally partial (build.sh uses "make MAKEINFO=true && true" to
# tolerate failures). Only libiberty, bfd, opcodes, and zlib libraries
# are fully built. Most subdirectories (binutils, gas, gold, bfd, opcodes)
# do not have generated Makefiles and cannot run tests.
#
# Available tests:
#   - libiberty/testsuite: demangle (698 tests), expandargv (7 tests),
#     pexecute, strtol (21 tests)
#
# Excluded components (with reasons):
#   - bfd: No Makefile generated (partial build)
#   - opcodes: No Makefile generated (partial build)
#   - binutils: No Makefile generated (partial build, bison missing)
#   - gas: No Makefile generated (partial build)
#   - gold: No Makefile generated (partial build)
#   - ld: flex missing, cannot regenerate lexer
#   - zlib: No real check target (just runs 'true')
#   - libctf: No Makefile generated
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Disable ASAN leak detection - libiberty tests have benign leaks
# (e.g. dupargv in test-expandargv) that are not real bugs
export ASAN_OPTIONS=detect_leaks=0

cd ${SRC:-/src}/binutils-gdb

echo "=== Running libiberty tests ==="
cd libiberty
make check

echo "All tests passed!"
exit 0
