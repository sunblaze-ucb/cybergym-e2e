#!/usr/bin/env bash

PROJECT_DIR="${SRC:-/src}/PcapPlusPlus"
cd "$PROJECT_DIR"

echo "=== Running tests for PcapPlusPlus ==="

# Function to run tests and capture results
run_test() {
    local test_name="$1"
    shift
    echo "Trying: $test_name"
    if "$@" 2>&1; then
        echo "✓ $test_name succeeded"
        return 0
    else
        echo "✗ $test_name failed or not available"
        return 1
    fi
}

# Try common test commands in order of likelihood
TEST_PASSED=false

# 1. Try make test (very common)
if [ -f "Makefile" ] || [ -f "makefile" ] || [ -f "GNUmakefile" ]; then
    if run_test "make test" make test -j$(nproc); then
        TEST_PASSED=true
    elif run_test "make check" make check -j$(nproc); then
        TEST_PASSED=true
    fi
fi

# 2. Try CMake/CTest
if [ "$TEST_PASSED" = false ] && [ -f "CMakeLists.txt" ]; then
    if command -v ctest &> /dev/null; then
        if run_test "ctest" ctest --output-on-failure; then
            TEST_PASSED=true
        fi
    fi
fi

# 3. Try Ninja
if [ "$TEST_PASSED" = false ] && [ -f "build.ninja" ]; then
    if command -v ninja &> /dev/null; then
        if run_test "ninja test" ninja test; then
            TEST_PASSED=true
        fi
    fi
fi

# 4. Try Meson
if [ "$TEST_PASSED" = false ] && [ -f "meson.build" ]; then
    if command -v meson &> /dev/null; then
        if run_test "meson test" meson test; then
            TEST_PASSED=true
        fi
    fi
fi

# 5. Language-specific test runners
if [ "$TEST_PASSED" = false ]; then
    # Python
    if [ -f "setup.py" ] || [ -f "pyproject.toml" ] || [ -f "pytest.ini" ]; then
        if command -v pytest &> /dev/null; then
            if run_test "pytest" pytest; then
                TEST_PASSED=true
            fi
        elif command -v python &> /dev/null; then
            if run_test "python -m unittest" python -m unittest discover; then
                TEST_PASSED=true
            fi
        fi
    fi

    # Rust
    if [ -f "Cargo.toml" ] && command -v cargo &> /dev/null; then
        if run_test "cargo test" cargo test; then
            TEST_PASSED=true
        fi
    fi

    # Go
    if [ -f "go.mod" ] && command -v go &> /dev/null; then
        if run_test "go test" go test ./...; then
            TEST_PASSED=true
        fi
    fi
fi

# Final result
if [ "$TEST_PASSED" = true ]; then
    echo ""
    echo "========================================="
    echo "✓ Tests completed successfully"
    echo "========================================="
    exit 0
else
    echo ""
    echo "========================================="
    echo "⚠ Warning: No suitable test command found or all tests failed"
    echo "You may need to manually configure test.sh for this project"
    echo "========================================="
    exit 1
fi
