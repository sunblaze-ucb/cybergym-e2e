#!/usr/bin/env bash
# test.sh - ALL unit tests for ffmpeg (oss-fuzz)
#
# This script runs the COMPLETE FATE (FFmpeg Automated Testing Environment) test suite
# for the ffmpeg project. This includes all available unit tests for libavutil, libavcodec,
# libavformat, libswscale, and checkasm tests.
#
# Note: This is an OSS-Fuzz build, so only internal FATE tests run (not external sample tests).
# The build is configured with sanitizers and has disabled many components (encoders, parsers,
# filters, etc.) for fuzzing purposes.
#
# Excluded tests (with reasons):
#   - fate-libavcodec-huffman: Build target libavcodec/tests/mjpegenc_huffman does not exist
#     in this build configuration (make: *** No rule to make target 'libavcodec/tests/mjpegenc_huffman')
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/ffmpeg

mkdir -p samples
make fate-rsync SAMPLES=samples

# Get the full FATE test list and exclude fate-libavcodec-huffman
# (its build target libavcodec/tests/mjpegenc_huffman doesn't exist in this configuration)
FATE_TESTS=$(make fate-list 2>/dev/null | grep -v "fate-libavcodec-huffman" | tr '\n' ' ')

make $FATE_TESTS SAMPLES=samples

echo "All tests passed!"
exit 0
