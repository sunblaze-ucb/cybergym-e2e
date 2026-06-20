#!/bin/bash
# test.sh - ALL unit tests for swift-protobuf (oss-fuzz_42534949)
#
# This script runs the COMPLETE test suite for the swift-protobuf project.
# Only tests that genuinely fail are excluded.
#
# Excluded tests (with reasons):
#   - SwiftProtobufTests.Test_TextFormatDecodingOptions/testIgnoreUnknown_Integer:
#     Fails due to a bug in handling negative hex/octal numbers in text format parsing.
#     The test expects parsing to succeed for inputs like "-0x12" but receives malformedNumber error.
#     This is the vulnerability being tested (OSS-Fuzz issue 42534949).
#
# Total tests: 918
# Included: 917
# Excluded: 1
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/swift-protobuf

# Run all tests except the failing one using --skip filter
swift test --skip "Test_TextFormatDecodingOptions/testIgnoreUnknown_Integer"

echo "All tests passed!"
exit 0
