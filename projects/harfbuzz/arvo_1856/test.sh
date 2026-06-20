#!/bin/bash
# test.sh - ALL unit tests for harfbuzz (arvo_1856)
#
# This script runs the COMPLETE test suite for the harfbuzz project.
# The project uses autotools as its build system (autogen.sh + configure + make).
#
# Since compile.sh produces an MSan-instrumented fuzzer build, this script
# performs a clean autotools build without sanitizers for running the test suite.
#
# Test Statistics:
#   Total tests: 63 (9 in src/ + 13 in test/api/ + 41 in test/shaping/)
#   Included: 63
#   Excluded: 0
#
# Test suites:
#   src/ (9 tests): check-c-linkage-decls.sh, check-defs.sh, check-externs.sh,
#     check-header-guards.sh, check-includes.sh, check-libstdc++.sh,
#     check-static-inits.sh, check-symbols.sh, test-ot-tag
#   test/api/ (13 tests): test-blob, test-buffer, test-common, test-font,
#     test-object, test-set, test-shape, test-unicode, test-version, test-ot-tag,
#     test-ot-math, test-c, test-cplusplus
#   test/shaping/ (41 tests): arabic-fallback-shaping, arabic-feature-order,
#     arabic-like-joining, arabic-mark-order, arabic-stch, automatic-fractions,
#     cluster, color-fonts, context-matching, cursive-positioning,
#     default-ignorables, emoji-flag-tags, fallback-positioning, fuzzed,
#     hangul-jamo, hyphens, indic-consonant-with-stacker, indic-init,
#     indic-joiner-candrabindu, indic-joiners, indic-old-spec, indic-pref-blocking,
#     indic-script-extensions, indic-special-cases, indic-syllable, language-tags,
#     ligature-id, mark-attachment, mark-filtering-sets, mongolian-variation-selector,
#     spaces, simple, tibetan-contractions-1, tibetan-contractions-2, tibetan-vowels,
#     use, use-marchen, use-syllable, variations-rvrn, vertical, zero-width-marks
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

# Install test dependencies (glib, freetype needed for full test suite)
apt-get update -qq 2>/dev/null
apt-get install -y -qq libglib2.0-dev libfreetype6-dev 2>&1 | tail -2

cd /src/harfbuzz

# Clean any previous fuzzer build artifacts and rebuild for testing
# (compile.sh produces MSan-instrumented binaries not suitable for unit tests)
unset CFLAGS CXXFLAGS LDFLAGS CC CXX SANITIZER FUZZING_ENGINE
export CC=gcc
export CXX=g++

make clean 2>/dev/null || true
make distclean 2>/dev/null || true

# Re-run autogen to regenerate makefiles with clean environment
./autogen.sh 2>&1 | tail -5
./configure 2>&1 | tail -5
make -j$(nproc) 2>&1 | tail -5

# Run the full test suite
make check

echo "All tests passed!"
exit 0
