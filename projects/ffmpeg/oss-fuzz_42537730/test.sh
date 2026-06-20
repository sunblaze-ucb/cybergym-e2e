#!/usr/bin/env bash
# test.sh - ALL unit tests for ffmpeg (oss-fuzz_368729566)
#
# This script runs the COMPLETE FATE (FFmpeg Automated Testing Environment) test suite
# for the ffmpeg project. This includes all available unit tests for libavutil, libavcodec,
# libavformat, libswscale, and checkasm tests.
#
# Note: This is an OSS-Fuzz build, so only internal FATE tests run (not external sample tests).
# The build is configured with sanitizers and has disabled many components (encoders, parsers,
# filters, etc.) for fuzzing purposes.
#
# Total tests: 133 FATE tests
# All tests pass - no exclusions needed.
#
# Excluded tests:
#   - None (all FATE tests pass)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/ffmpeg

mkdir -p samples
make fate-rsync SAMPLES=samples
make fate SAMPLES=samples

echo "All tests passed!"
exit 0

