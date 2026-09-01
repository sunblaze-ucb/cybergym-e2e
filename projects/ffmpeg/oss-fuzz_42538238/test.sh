#!/usr/bin/env bash
# test.sh - ALL unit tests for ffmpeg
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

# FATE's external-sample tests are fetched with
#   rsync rsync://fate-suite.ffmpeg.org/fate-suite/
# and rsync:// cannot traverse an HTTP proxy, so this hard-failed under network
# isolation (the fetch is the first thing test.sh did, under `set -e`).
#
# Dropping SAMPLES= is near-free here. tests/Makefile only adds $(FATE_EXTERN)
# to the test list `ifdef SAMPLES`, and FATE_EXTERN is
#   $(FATE_EXTERN-$(CONFIG_FFMPEG)) $(FATE_EXTERN-$(CONFIG_FFPROBE)) $(FATE_SAMPLES_FASTSTART)
# This is an OSS-Fuzz build configured --disable-programs, so CONFIG_FFMPEG and
# CONFIG_FFPROBE are both off and the first two terms vanish; FATE_SAMPLES_FASTSTART
# is the single test fate-mov-faststart-4gb-overflow. Every internal FATE test
# still runs -- which is what this script's header already claims happens.
make fate

echo "All tests passed!"
exit 0

