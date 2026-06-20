#!/bin/bash
# test.sh - ALL unit tests for harfbuzz (arvo_4099)
#
# This runs the COMPLETE test suite for the harfbuzz project, excluding only
# tests that genuinely fail on the vulnerable version of the code.
#
# The compile.sh step builds harfbuzz with MSan sanitizer flags for fuzzing.
# Tests require a clean autotools build, so we reconfigure and rebuild here
# with standard compiler settings.
#
# Test Statistics:
#   src/ checks:       9 tests (9 pass)
#   test/api/ tests:   13 tests (13 pass)
#   test/shaping/:     41 tests (40 pass, 1 excluded)
#   Total:             63 tests
#   Included:          62
#   Excluded:          1
#
# Excluded tests (with reasons):
#   - tests/fallback-positioning.tests: Shaping output mismatch in glyph
#     positioning (actual vs expected values differ in x-offset and y-offset
#     for combining accent marks). This is a pre-existing test failure in this
#     version of harfbuzz (1.6.3), not related to our test setup.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

SRC_DIR="${SRC:-/src}/harfbuzz"
cd "$SRC_DIR"

# Install build dependencies needed for the test build
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq libglib2.0-dev libfreetype6-dev pkg-config autoconf automake libtool ragel > /dev/null 2>&1

# Clean the MSan-instrumented build from compile.sh and rebuild cleanly
# for testing. The MSan build causes check-defs.sh and check-symbols.sh
# to fail because exported symbols differ from the expected .def file.
make distclean > /dev/null 2>&1 || true
unset CC CXX CFLAGS CXXFLAGS LDFLAGS

# Reconfigure with standard compiler and build
./configure --without-cairo --without-gobject --without-icu > /dev/null 2>&1
make -j"$(nproc)" > /dev/null 2>&1

echo "=== Running src/ checks (9 tests) ==="
make -C src check 2>&1

echo ""
echo "=== Running test/api/ tests (13 tests) ==="
make -C test/api check 2>&1

echo ""
echo "=== Running test/shaping/ tests (40 of 41 tests, excluding fallback-positioning) ==="
SHAPING_TESTS="\
tests/arabic-fallback-shaping.tests \
tests/arabic-feature-order.tests \
tests/arabic-like-joining.tests \
tests/arabic-mark-order.tests \
tests/arabic-stch.tests \
tests/automatic-fractions.tests \
tests/cluster.tests \
tests/color-fonts.tests \
tests/context-matching.tests \
tests/cursive-positioning.tests \
tests/default-ignorables.tests \
tests/emoji-flag-tags.tests \
tests/fuzzed.tests \
tests/hangul-jamo.tests \
tests/hyphens.tests \
tests/indic-consonant-with-stacker.tests \
tests/indic-init.tests \
tests/indic-joiner-candrabindu.tests \
tests/indic-joiners.tests \
tests/indic-old-spec.tests \
tests/indic-pref-blocking.tests \
tests/indic-script-extensions.tests \
tests/indic-special-cases.tests \
tests/indic-syllable.tests \
tests/language-tags.tests \
tests/ligature-id.tests \
tests/mark-attachment.tests \
tests/mark-filtering-sets.tests \
tests/mongolian-variation-selector.tests \
tests/spaces.tests \
tests/simple.tests \
tests/tibetan-contractions-1.tests \
tests/tibetan-contractions-2.tests \
tests/tibetan-vowels.tests \
tests/use.tests \
tests/use-marchen.tests \
tests/use-syllable.tests \
tests/variations-rvrn.tests \
tests/vertical.tests \
tests/zero-width-marks.tests"

make -C test/shaping check TESTS="$SHAPING_TESTS" 2>&1

echo ""
echo "All tests passed!"
exit 0
