#!/bin/bash
# test.sh - ALL unit tests for harfbuzz (oss-fuzz_433311398)
#
# Build image: cybergym/e2e:harfbuzz
#
# Test Statistics:
#   Total: 59 | Included: 59 | Excluded: 0
#
# All tests pass on the current image - no exclusions needed.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/harfbuzz

# Setup meson build if not already present
if [ ! -d build ]; then
    meson setup build --wrap-mode=nofallback
fi

cd build

# Build
ninja

# Run the full test suite
meson test --no-rebuild --print-errorlogs

echo "All tests passed!"
exit 0
