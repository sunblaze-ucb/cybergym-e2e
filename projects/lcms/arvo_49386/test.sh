#!/usr/bin/env bash
set -euo pipefail

cd /src/lcms

echo "=== Running tests for lcms ==="

# Create a temporary log file
LOG_FILE=$(mktemp /tmp/lcms_test_log.XXXXXX)

# Patch the test to handle the stricter validation in the patched version
# The patch rejects profiles with no tags, but the test creates placeholder profiles
if grep -q "Corrupted profile: no tags found" src/cmsio0.c 2>/dev/null; then
    echo "Patching test for stricter validation..."
    
    # Backup original test
    cp testbed/testcms2.c testbed/testcms2.c.backup
    
    # Fix the CheckVersionHeaderWriting test to add a minimal tag
    sed -i '/cmsSetProfileVersion(h, test_versions\[index\]);/i \
      \/\/ Add a minimal tag so the profile is valid (patch requires at least one tag)\
      cmsMLU* mlu = cmsMLUalloc(DbgThread(), 1);\
      cmsMLUsetASCII(mlu, "en", "US", "Test");\
      cmsWriteTag(h, cmsSigProfileDescriptionTag, mlu);\
      cmsMLUfree(mlu);' testbed/testcms2.c
fi

# Run the test suite
make check | tee "$LOG_FILE"

# Check if tests passed
if [ $? -eq 0 ]; then
    echo "✓ All tests passed successfully"
    exit 0
else
    echo "✗ Tests failed - see log above"
    exit 1
fi
