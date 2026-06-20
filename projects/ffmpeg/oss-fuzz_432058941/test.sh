#!/usr/bin/env bash
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

