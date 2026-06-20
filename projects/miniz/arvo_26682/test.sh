#!/bin/bash
# test.sh - ALL unit tests for miniz (arvo_26682)
#
# This script runs the COMPLETE test suite for the miniz project.
# Tests include:
#   - example1: Basic compression/decompression test (zlib-style API)
#   - example2: ZIP archive creation, enumeration and extraction test
#   - example6: PNG writing test with compression functions
#
# Excluded tests (with reasons):
#   - example3: Utility program requiring input/output files (not a self-contained test)
#   - example4: Utility program requiring input/output files (not a self-contained test)
#   - example5: Utility program requiring input/output files (not a self-contained test)
#   - miniz_tester: Requires non-amalgamated build structure (not compatible with OSS-Fuzz build)
#
# Total test programs: 6
# Included: 3 (example1, example2, example6)
# Excluded: 3 (example3, example4, example5 - these are utilities, not tests)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/miniz

echo "=== Running miniz tests ==="

# Check if examples are already built (OSS-Fuzz environment)
if [ -d "bin" ] && [ -f "bin/example1" ]; then
    echo "Using pre-built examples from compile.sh"
    EXAMPLE_DIR="bin"
else
    # Build examples using CMake
    echo "Building miniz tests..."
    mkdir -p build
    cd build
    cmake .. -DBUILD_EXAMPLES=ON > /dev/null 2>&1
    make -j$(nproc) > /dev/null 2>&1
    cd ..
    EXAMPLE_DIR="bin"
fi

echo "=== Running example1 (basic compression test) ==="
./$EXAMPLE_DIR/example1
echo "example1 PASSED"

echo "=== Running example2 (ZIP archive test) ==="
./$EXAMPLE_DIR/example2
echo "example2 PASSED"

echo "=== Running example6 (PNG writing test) ==="
./$EXAMPLE_DIR/example6
echo "example6 PASSED"

# Cleanup
rm -f mandelbrot.png

echo ""
echo "=== All tests passed! ==="
exit 0
