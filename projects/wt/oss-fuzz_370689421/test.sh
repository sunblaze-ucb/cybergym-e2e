#!/bin/bash
# test.sh - ALL unit tests for wt (oss-fuzz_370689421)
#
# This script runs the COMPLETE test suite for the wt project.
# Only tests that genuinely fail are excluded.
#
# Test binaries available:
#   - test.wt: Main Wt library tests (319 tests, 17 excluded)
#   - thirdpartytest.wt: Third-party library tests (21 tests, all passing)
#   - test.sqlite3: SQLite3 DBO tests (92 tests, all passing)
#   - test.http: HTTP client/server tests (16 tests, all passing)
#
# Excluded tests from test.wt (with reasons):
#   - json_utf8_test: Missing test resource file (UTF-8 JSON test data)
#   - json_generate_UTF8: Missing test resource file (UTF-8 JSON serialization data)
#   - Message_header_RFC5322_date: Missing mail/out/*.xml test resource files
#   - I18n_messageResourceBundleTest: Missing private/i18n/plain.xml resource
#   - I18n_pluralResourceBundleException1: Missing private/i18n/*.xml resource
#   - I18n_pluralResourceBundleException2: Missing private/i18n/*.xml resource
#   - I18n_pluralResourceBundleException3: Missing private/i18n/*.xml resource
#   - I18n_pluralResourceBundleException4: Missing private/i18n/*.xml resource
#   - I18n_pluralResourceBundleException5: Missing private/i18n/*.xml resource
#   - I18n_pluralResourceBundle1: Missing private/i18n/plural.xml resource
#   - I18n_findCaseException1: Missing private/i18n/plural_findcase_err1.xml
#   - I18n_findCaseException2: Missing private/i18n/plural_findcase_err2.xml
#   - I18n_internalArgument1: Missing private/i18n/international_argument_1.xml
#   - I18n_toXhtmlUTF8: Missing private/i18n/toxhtml.xml resource
#   - CssParser_testDefaultStylesheet: Missing ../resources/html4_default.css
#   - WDate_toString_localized: Missing localization xml resource
#   - WDateTime_toString_localized: Missing localization xml resource
#
# Total tests: 448
# Included: 431
# Excluded: 17
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/wt/mybuild/test

echo "Running test.wt (main Wt library tests, excluding 17 failing tests due to missing resources)..."
./test.wt \
    --run_test='!json_utf8_test' \
    --run_test='!json_generate_UTF8' \
    --run_test='!Message_header_RFC5322_date' \
    --run_test='!I18n_messageResourceBundleTest' \
    --run_test='!I18n_pluralResourceBundleException1' \
    --run_test='!I18n_pluralResourceBundleException2' \
    --run_test='!I18n_pluralResourceBundleException3' \
    --run_test='!I18n_pluralResourceBundleException4' \
    --run_test='!I18n_pluralResourceBundleException5' \
    --run_test='!I18n_pluralResourceBundle1' \
    --run_test='!I18n_findCaseException1' \
    --run_test='!I18n_findCaseException2' \
    --run_test='!I18n_internalArgument1' \
    --run_test='!I18n_toXhtmlUTF8' \
    --run_test='!CssParser_testDefaultStylesheet' \
    --run_test='!WDate_toString_localized' \
    --run_test='!WDateTime_toString_localized' \
    --log_level=test_suite --report_level=short
echo "test.wt passed!"

echo ""
echo "Running thirdpartytest.wt (third-party library tests)..."
./thirdpartytest.wt --log_level=test_suite --report_level=short
echo "thirdpartytest.wt passed!"

echo ""
echo "Running test.sqlite3 (SQLite3 DBO tests)..."
./test.sqlite3 --log_level=test_suite --report_level=short
echo "test.sqlite3 passed!"

echo ""
echo "Running test.http (HTTP client/server tests)..."
./test.http --log_level=test_suite --report_level=short
echo "test.http passed!"

echo ""
echo "All tests passed!"
exit 0
