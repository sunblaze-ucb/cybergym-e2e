#!/usr/bin/env bash
# test.sh - ALL unit tests for tinygltf (arvo_42123)
#
# This script runs the COMPLETE test suite for the tinygltf project.
# Tests are built and run using Catch2 framework.
#
# Test suites:
#   - tester: Standard tests (17 test cases, 98 assertions)
#   - tester_noexcept: Tests with TINYGLTF_NOEXCEPTION (17 test cases, 98 assertions)
#
# Excluded tests: None
#   All 17 tests pass in both configurations:
#   - parse-error [parse]
#   - datauri-in-glb [issue-79]
#   - extension-with-empty-object [issue-97]
#   - extension-overwrite [issue-261]
#   - invalid-primitive-indices [bounds-checking]
#   - invalid-buffer-view-index [bounds-checking]
#   - invalid-buffer-index [bounds-checking]
#   - glb-invalid-length [bounds-checking]
#   - integer-out-of-bounds [bounds-checking]
#   - parse-integer [bounds-checking]
#   - parse-unsigned [bounds-checking]
#   - parse-integer-array [bounds-checking]
#   - pbr-khr-texture-transform [material]
#   - image-uri-spaces [issue-236]
#   - serialize-empty-material [issue-294]
#   - empty-skeleton-id [issue-321]
#   - expandpath-utf-8 [pr-226]
#
# Total tests: 34 (17 in tester + 17 in tester_noexcept)
# Included: 34
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/tinygltf/tests

echo "=== Building tinygltf tests ==="
make all

echo ""
echo "=== Running tester (standard mode) ==="
./tester

echo ""
echo "=== Running tester_noexcept (NOEXCEPTION mode) ==="
./tester_noexcept

echo ""
echo "All tests passed!"
exit 0
