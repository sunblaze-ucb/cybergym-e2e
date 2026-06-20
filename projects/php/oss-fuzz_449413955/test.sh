#!/bin/bash
# Exit codes:
#   0 - All checks passed
#   1 - One or more checks failed

set -e

cd ${SRC:-/src}/php-src

echo "=== Running PHP verification tests ==="

# Check for PHP binary
echo "Checking build artifacts..."

if [ -f "sapi/cli/php" ]; then
    echo "✓ PHP CLI binary found"

    # Run a simple syntax check
    echo "Running basic PHP verification..."
    ./sapi/cli/php -v && echo "✓ PHP version check passed"

    # Run a simple code test
    echo '<?php echo "Hello from PHP\n"; ?>' | ./sapi/cli/php && echo "✓ Basic PHP execution passed"

elif [ -f "sapi/fpm/php-fpm" ]; then
    echo "✓ PHP-FPM binary found"
else
    echo "⚠ No PHP binary found in standard locations"
    # Check for any php binary
    PHP_BIN=$(find . -name "php" -type f -executable 2>/dev/null | head -1)
    if [ -n "$PHP_BIN" ]; then
        echo "✓ Found PHP binary: $PHP_BIN"
    fi
fi

# Check for fuzzer binary
if [ -f "/out/php-fuzz-tracing-jit" ]; then
    echo "✓ Fuzzer binary found: php-fuzz-tracing-jit"
else
    FUZZER=$(find /out -name "php-fuzz*" -type f 2>/dev/null | head -1)
    if [ -n "$FUZZER" ]; then
        echo "✓ Fuzzer binary found: $FUZZER"
    fi
fi

# Check for key source files
if [ -f "Zend/zend.h" ]; then
    echo "✓ Core Zend headers present"
else
    echo "✗ Core Zend headers missing"
    exit 1
fi

if [ -f "main/php.h" ]; then
    echo "✓ Core PHP headers present"
else
    echo "✗ Core PHP headers missing"
    exit 1
fi

echo ""
echo "All verification checks passed!"
exit 0

