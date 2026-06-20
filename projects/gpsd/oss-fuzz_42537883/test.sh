#!/bin/bash
# test.sh - ALL unit tests for gpsd (oss-fuzz_42537883)
#
# This script runs the COMPLETE test suite for the gpsd project.
# It first builds the test binaries (since the fuzz compile step
# does not build them), then runs all available tests.
#
# Build system: scons
# Source: /src/gpsd
# Variant dir: /src/gpsd/gpsd-3.25.1~dev
#
# Excluded tests (with reasons):
#   - test_packet: Fails to link (undefined reference to pthread_create)
#   - test_timespec: Fails to link (same pthread issue as test_packet)
#   - test_gpsmm: C++ test, same linker issue with pthread
#   - test_libgps: Requires a running gpsd daemon (exits with error -6)
#   - test_xgps_deps.py: Missing cairo Python module in container
#   - unpack_regress: regress-driver cannot find test_libgps in expected path
#   - method_regress: Requires test_packet which cannot build
#   - packet_regress: Requires test_packet which cannot build
#   - nmea2000_regress: Requires CAN device (vcan0) not available in container
#   - gps_regress/daemon tests: Require gpsfake + gpsd daemon running
#   - gpsfake_tests: Require gpsd daemon infrastructure
#
# Total test categories: 20+
# Included: 13 (covering unit tests, regression tests, and Python tests)
# Excluded: 8+ (due to build/environment limitations)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

SRCDIR="/src/gpsd"
BUILDDIR="/src/gpsd/gpsd-3.25.1~dev"
TESTBIN="${BUILDDIR}/tests"
GPSDECODE="${BUILDDIR}/clients/gpsdecode"

cd "$SRCDIR"

echo "=== Building gpsd test binaries ==="

# Build test binaries that can link successfully.
# test_packet, test_timespec, test_gpsmm fail to link due to missing pthread.
# We build only the tests that succeed.
scons -Q \
    gpsd-3.25.1~dev/tests/test_bits \
    gpsd-3.25.1~dev/tests/test_float \
    gpsd-3.25.1~dev/tests/test_geoid \
    gpsd-3.25.1~dev/tests/test_gpsdclient \
    gpsd-3.25.1~dev/tests/test_matrix \
    gpsd-3.25.1~dev/tests/test_mktime \
    gpsd-3.25.1~dev/tests/test_json \
    gpsd-3.25.1~dev/tests/test_trig \
    gpsd-3.25.1~dev/tests/test_libgps \
    2>&1

echo "=== Running gpsd unit tests ==="

# --- C Unit Tests ---

# 1. test_bits (bits-regress): bitfield extraction unit test
echo "Running test_bits..."
"${TESTBIN}/test_bits" --quiet
echo "PASS: test_bits"

# 2. test_float (float-regress): floating point math
echo "Running test_float..."
"${TESTBIN}/test_float"
echo "PASS: test_float"

# 3. test_geoid (geoid-regress): geoid and variation models
echo "Running test_geoid..."
"${TESTBIN}/test_geoid"
echo "PASS: test_geoid"

# 4. test_gpsdclient (deg-regress): degree conversion
echo "Running test_gpsdclient..."
"${TESTBIN}/test_gpsdclient"
echo "PASS: test_gpsdclient"

# 5. test_matrix (matrix-regress): matrix algebra
echo "Running test_matrix..."
"${TESTBIN}/test_matrix" --quiet
echo "PASS: test_matrix"

# 6. test_mktime (time-regress): calendar functions
echo "Running test_mktime..."
"${TESTBIN}/test_mktime"
echo "PASS: test_mktime"

# 7. test_json (json-regress): JSON parsing
echo "Running test_json..."
"${TESTBIN}/test_json"
echo "PASS: test_json"

# 8. test_trig (trig-regress): trigonometric math
echo "Running test_trig..."
"${TESTBIN}/test_trig" > /dev/null
echo "PASS: test_trig"

# --- Regression Tests ---

# 9. RTCM2 regression: decode RTCM2 binary data
echo "Running RTCM2 regression tests..."
for f in test/*.rtcm2; do
    TMPFILE=$(mktemp)
    "${GPSDECODE}" -u -j < "${f}" > "${TMPFILE}"
    diff -ub "${f}".chk "${TMPFILE}"
    rm -f "${TMPFILE}"
done
echo "PASS: rtcm2-regress"

# 10. RTCM2 idempotency: JSON dump/decode roundtrip
echo "Running RTCM2 idempotency test..."
TMPFILE=$(mktemp)
"${GPSDECODE}" -u -e -j < test/synthetic-rtcm2.json > "${TMPFILE}"
grep -v "^#" test/synthetic-rtcm2.json | diff -ub - "${TMPFILE}"
rm -f "${TMPFILE}"
echo "PASS: rtcm2-idempotency"

# 11. AIVDM regression: decode AIS/AIVDM data (5 subtests)
echo "Running AIVDM regression tests..."
"${GPSDECODE}" -u -c < test/sample.aivdm | diff -ub test/sample.aivdm.chk -
"${GPSDECODE}" -j < test/sample.aivdm | diff -ub test/sample.aivdm.js.chk -
"${GPSDECODE}" -u -j < test/sample.aivdm | diff -ub test/sample.aivdm.ju.chk -
"${GPSDECODE}" -u -e -j < test/sample.aivdm.ju.chk | diff -ub test/sample.aivdm.ju.chk -
"${GPSDECODE}" -e -j < test/sample.aivdm.ju.chk | diff -ub test/sample.aivdm.js.chk -
echo "PASS: aivdm-regress"

# --- Python Tests ---

# 12. test_clienthelpers.py: client helper functions
echo "Running test_clienthelpers.py..."
PYTHONPATH="${BUILDDIR}" python3 tests/test_clienthelpers.py
echo "PASS: test_clienthelpers.py"

# 13. test_misc.py: miscellaneous utility functions
echo "Running test_misc.py..."
PYTHONPATH="${BUILDDIR}" python3 tests/test_misc.py
echo "PASS: test_misc.py"

echo ""
echo "========================================="
echo "All tests passed!"
echo "========================================="
exit 0
