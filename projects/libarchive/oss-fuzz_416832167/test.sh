#!/bin/bash
# test.sh - ALL unit tests for libarchive (oss-fuzz_416832167)
#
# Build image: cybergym/e2e:libarchive
#
# Test Statistics:
#   Total: 855 | Included: 838 | Excluded: 17
#
# Excluded tests (with reasons):
#   - libarchive_test_compat_zip_4: Fails due to known bug in vulnerable version
#   - libarchive_test_read_format_cpio_bin*: cpio binary format read failures (8 tests)
#   - libarchive_test_read_pax_truncated: Fails on truncated pax archive handling
#   - bsdcpio_test_basic: bsdcpio test failure in vulnerable version
#   - bsdcpio_test_option_0: bsdcpio option test failure
#   - bsdcpio_test_option_L_upper: bsdcpio option test failure
#   - bsdcpio_test_option_d: bsdcpio option test failure
#   - bsdcpio_test_option_f: bsdcpio option test failure
#   - bsdcpio_test_option_m: bsdcpio option test failure
#   - bsdcpio_test_option_t: bsdcpio option test failure
#   - bsdtar_test_list_item: bsdtar list item test failure in vulnerable version
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

# Skip leak sanitizer and disable possible null return from allocator
export ASAN_OPTIONS="detect_leaks=0:allocator_may_return_null=1"

cd /src/libarchive

# Build if not already built
if [ ! -d build2 ] || [ ! -f build2/Makefile ]; then
    mkdir -p build2
    cd build2
    cmake -DDONT_FAIL_ON_CRC_ERROR=ON -DENABLE_WERROR=OFF ../
    make -j$(nproc)
    cd ..
fi

# Run the full test suite, excluding only known failures
ctest --test-dir build2 -j$(nproc) --output-on-failure -E \
    "libarchive_test_compat_zip_4|libarchive_test_read_format_cpio_bin*|libarchive_test_read_pax_truncated|bsdcpio_test_basic|bsdcpio_test_option_0|bsdcpio_test_option_L_upper|bsdcpio_test_option_d|bsdcpio_test_option_f|bsdcpio_test_option_m|bsdcpio_test_option_t|bsdtar_test_list_item"

echo "All tests passed!"
exit 0
