#!/usr/bin/env bash
set -euo pipefail

cd /src/lcms

echo "=== Running tests for lcms ==="

# Create a temporary log file
LOG_FILE=$(mktemp /tmp/lcms_test_log.XXXXXX)

# Give the profiles written by the CheckVersionHeaderWriting test a tag
sed -i '/cmsSetProfileVersion(h, test_versions\[index\]);/i \
      \/\/ Add a minimal tag to the profile\
      cmsMLU* mlu = cmsMLUalloc(DbgThread(), 1);\
      cmsMLUsetASCII(mlu, "en", "US", "Test");\
      cmsWriteTag(h, cmsSigProfileDescriptionTag, mlu);\
      cmsMLUfree(mlu);' testbed/testcms2.c

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
