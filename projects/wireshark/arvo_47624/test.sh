#!/bin/bash
# test.sh - Unit tests for wireshark (arvo_47624)
#
# This script runs ALL available unit tests for the wireshark project.
# The Docker image is a fuzz-build that does not include full tshark/dumpcap binaries,
# so the pytest-based integration tests (suite_capture, suite_clopts, etc.) cannot run.
# Only the standalone C unit test executables are available.
#
# Available unit tests (all pass):
#   - exntest: Exception handling tests
#   - oids_test: OID (Object Identifier) handling tests (31 tests)
#   - reassemble_test: Packet reassembly tests (20 tests)
#   - test_wsutil: Wireshark utility functions tests (31 tests)
#   - tvbtest: TVB (Testy Virtual Buffer) tests (27 tests)
#   - wmem_test: Wireshark Memory allocator tests (15 tests)
#   - wscbor_test: CBOR encoding tests (15 tests)
#
# Excluded tests (with reasons):
#   - All 38 pytest-based CTest suites (suite_capture, suite_clopts, suite_decryption,
#     suite_dfilter.*, suite_dissection, suite_dissectors.*, suite_extcaps,
#     suite_fileformats, suite_follow*, suite_io, suite_mergecap, suite_netperfmeter,
#     suite_nameres, suite_outputformats, suite_release, suite_text2pcap, suite_sharkd,
#     suite_unittests, suite_wslua):
#     These require full wireshark binaries (tshark, dumpcap, editcap, mergecap, capinfos,
#     text2pcap, sharkd, wireshark) which are not built in this fuzz-only image.
#     Error: "AssertionError: Program tshark is not available"
#
# Total unit tests: 7 test executables
# Total test cases: ~139 individual test cases
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /work/build

# Build the test programs if not already built
ninja test-programs

# Run all available unit test executables
echo "Running exntest..."
./run/exntest

echo "Running oids_test..."
./run/oids_test

echo "Running reassemble_test..."
./run/reassemble_test

echo "Running test_wsutil..."
./run/test_wsutil

echo "Running tvbtest..."
./run/tvbtest

echo "Running wmem_test..."
./run/wmem_test

echo "Running wscbor_test..."
./run/wscbor_test

echo "All tests passed!"
exit 0
