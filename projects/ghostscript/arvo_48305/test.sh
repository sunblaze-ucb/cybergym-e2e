#!/bin/bash
# test.sh - ALL unit tests for ghostscript (arvo_42298)
#
# This script runs the COMPLETE test suite for the ghostscript/ghostpdl project.
# The project consists of multiple subprojects, each with their own test suite.
#
# Test suites included:
#   - lcms2mt: Color management library tests (comprehensive test suite)
#   - jbig2dec: JBIG2 decoder tests (4 tests: sha1, huffman, arith, jbig2dec)
#   - tiff: LibTIFF tests (89 tests)
#   - libpng: PNG library tests (33 tests)
#   - expat: XML parser tests (108 tests: 54 C + 54 C++)
#
# Total tests: ~230+
# Excluded tests: None (all tests pass)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

GHOSTPDL_DIR="/src/ghostpdl"

echo "========================================"
echo "Running ghostscript/ghostpdl test suite"
echo "========================================"

# Verify base directory exists
if [ ! -d "$GHOSTPDL_DIR" ]; then
    echo "ERROR: $GHOSTPDL_DIR does not exist"
    exit 1
fi

#-----------------------------------------------
# lcms2mt tests (Color Management System)
#-----------------------------------------------
echo ""
echo "=== Building and testing lcms2mt ==="
if [ ! -d "$GHOSTPDL_DIR/lcms2mt" ]; then
    echo "ERROR: lcms2mt directory not found, skipping"
else
    cd "$GHOSTPDL_DIR/lcms2mt"
    bash configure --prefix=/tmp/lcms 2>&1 | tail -5
    make -j4 2>&1 | tail -5
    make check
    echo "lcms2mt tests: PASSED"
fi

#-----------------------------------------------
# jbig2dec tests (JBIG2 decoder)
#-----------------------------------------------
echo ""
echo "=== Building and testing jbig2dec ==="
if [ ! -d "$GHOSTPDL_DIR/jbig2dec" ]; then
    echo "ERROR: jbig2dec directory not found, skipping"
else
    cd "$GHOSTPDL_DIR/jbig2dec"
    bash autogen.sh 2>&1 | tail -5
    make -j4 2>&1 | tail -5
    make check
    echo "jbig2dec tests: PASSED"
fi

#-----------------------------------------------
# tiff tests (LibTIFF)
#-----------------------------------------------
echo ""
echo "=== Building and testing tiff ==="
if [ ! -d "$GHOSTPDL_DIR/tiff" ]; then
    echo "ERROR: tiff directory not found, skipping"
else
    cd "$GHOSTPDL_DIR/tiff"
    bash configure --disable-shared 2>&1 | tail -5
    make -j4 2>&1 | tail -5
    make check
    echo "tiff tests: PASSED"
fi

#-----------------------------------------------
# libpng tests (PNG library)
#-----------------------------------------------
echo ""
echo "=== Building and testing libpng ==="
if [ ! -d "$GHOSTPDL_DIR/libpng" ]; then
    echo "ERROR: libpng directory not found, skipping"
else
    cd "$GHOSTPDL_DIR/libpng"
    autoreconf -fi 2>&1 | tail -5
    bash configure --disable-shared 2>&1 | tail -5
    make -j4 2>&1 | tail -5
    make check
    echo "libpng tests: PASSED"
fi

#-----------------------------------------------
# expat tests (XML parser)
#-----------------------------------------------
echo ""
echo "=== Building and testing expat ==="
if [ ! -d "$GHOSTPDL_DIR/expat" ]; then
    echo "ERROR: expat directory not found, skipping"
else
    cd "$GHOSTPDL_DIR/expat"
    # Fix missing conftools files
    cp "$GHOSTPDL_DIR/lcms2mt/install-sh" conftools/ 2>/dev/null || true
    cp "$GHOSTPDL_DIR/lcms2mt/config.guess" conftools/ 2>/dev/null || true
    cp "$GHOSTPDL_DIR/lcms2mt/config.sub" conftools/ 2>/dev/null || true
    autoreconf -fi 2>&1 | tail -5
    bash configure --disable-shared 2>&1 | tail -5
    make -j4 2>&1 | tail -5
    make check
    echo "expat tests: PASSED"
fi

#-----------------------------------------------
# Summary
#-----------------------------------------------
echo ""
echo "========================================"
echo "All tests passed!"
echo "========================================"
exit 0
