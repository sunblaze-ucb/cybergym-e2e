#!/usr/bin/env bash
set -eo pipefail

PROJECT_DIR="${SRC:-/src}/lua"
cd "$PROJECT_DIR"

echo "=== Running tests for lua ==="

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

TEST_PASSED=false

# 1. Build Lua interpreter if not already built (without readline to avoid dependency)
if [ ! -f "lua" ]; then
    echo "Building Lua interpreter for tests..."
    make clean || true
    # Build without readline support (use generic/minimal build)
    if make -j$(nproc) MYCFLAGS="-ULUA_USE_READLINE" MYLIBS="-lm -ldl" lua 2>&1; then
        # Ensure execute permissions
        chmod +x lua
        echo "✓ Lua interpreter built successfully"
    else
        echo "✗ Failed to build Lua interpreter"
        exit 1
    fi
else
    # Ensure execute permissions on existing binary
    chmod +x lua
fi

# 2. Run Lua's official test suite ( https://www.lua.org/tests/#complete )
if [ -d "testes" ] && [ -f "./lua" ]; then
    cd testes
    if run_test "Lua test suite" ../lua -e"_U=true" all.lua; then
        TEST_PASSED=true
        cd ..
    else
        cd ..
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
    echo "⚠ Warning: Tests failed"
    echo "========================================="
    exit 1
fi
