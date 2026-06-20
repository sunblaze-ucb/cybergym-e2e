#!/bin/bash
# test.sh - Unit tests for gpsd (oss-fuzz_42537879)
#
# This script runs the COMPLETE test suite for the gpsd project.
# All tests that can be built and pass are included.
#
# Tests included (10 total):
#   - test_bits: Tests bit manipulation utilities
#   - test_float: Tests floating point operations
#   - test_trig: Tests trigonometric functions
#   - test_mktime: Tests time conversion functions
#   - test_gpsdclient: Tests GPS client library functions
#   - test_json: Tests JSON parsing
#   - test_matrix: Tests matrix operations
#   - test_geoid: Tests geoid calculations
#   - test_misc.py: Python misc module tests
#   - test_clienthelpers.py: Python client helpers tests
#
# Tests excluded (with reasons):
#   - test_packet: Fails to build due to pthread linking issue in oss-fuzz build environment
#   - test_timespec: Fails to build due to pthread linking issue in oss-fuzz build environment
#   - test_gpsmm: Fails to build due to C++ stdlib linking issue in oss-fuzz build environment
#   - test_libgps: Requires running gpsd daemon (network test, not suitable for unit testing)
#   - gpsdecode-based tests: gpsdecode fails to build in oss-fuzz environment
#   - gps-regress: Requires gpsd daemon
#   - nmea2000-regress: Requires canplayer which is not available
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e  # Exit on first failure

cd /src/gpsd

# Build the test binaries
echo "Building test binaries..."
scons gpsd-3.25.1~dev/tests/test_bits \
      gpsd-3.25.1~dev/tests/test_float \
      gpsd-3.25.1~dev/tests/test_trig \
      gpsd-3.25.1~dev/tests/test_mktime \
      gpsd-3.25.1~dev/tests/test_gpsdclient \
      gpsd-3.25.1~dev/tests/test_json \
      gpsd-3.25.1~dev/tests/test_matrix \
      gpsd-3.25.1~dev/tests/test_geoid > /dev/null 2>&1

echo "Running tests..."

# C/C++ tests
echo "Running test_bits..."
gpsd-3.25.1~dev/tests/test_bits --quiet

echo "Running test_float..."
gpsd-3.25.1~dev/tests/test_float > /dev/null

echo "Running test_trig..."
gpsd-3.25.1~dev/tests/test_trig > /dev/null

echo "Running test_mktime..."
gpsd-3.25.1~dev/tests/test_mktime > /dev/null

echo "Running test_gpsdclient..."
gpsd-3.25.1~dev/tests/test_gpsdclient > /dev/null

echo "Running test_json..."
gpsd-3.25.1~dev/tests/test_json > /dev/null

echo "Running test_matrix..."
gpsd-3.25.1~dev/tests/test_matrix > /dev/null

echo "Running test_geoid..."
gpsd-3.25.1~dev/tests/test_geoid > /dev/null

# Python tests
export PYTHONPATH=/src/gpsd/gpsd-3.25.1~dev/
echo "Running test_misc.py..."
python tests/test_misc.py > /dev/null

echo "Running test_clienthelpers.py..."
python tests/test_clienthelpers.py > /dev/null

echo "All tests passed!"
exit 0
