#!/bin/bash
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Set ASAN options to prevent false positives during testing
export ASAN_OPTIONS=detect_leaks=0:allocator_may_return_null=1

# Set PATH to use built binaries (from compile.sh)
export PATH=/src/gpac/bin/gcc:$PATH

# Check if binaries exist
if [ ! -f /src/gpac/bin/gcc/gpac ] || [ ! -f /src/gpac/bin/gcc/MP4Box ]; then
    echo "ERROR: gpac binaries not found. Run compile.sh first."
    exit 1
fi

# Test media directory
MEDIA_DIR=/src/gpac/testsuite/media/auxiliary_files
TEMP_DIR=/tmp/gpac_tests
mkdir -p $TEMP_DIR

echo "=== Running GPAC Tests ==="

# Test 1: gpac help
echo "Test 1: gpac -h"
gpac -h > /dev/null 2>&1

# Test 2: gpac filters listing
echo "Test 2: gpac -h filters"
gpac -h filters > /dev/null 2>&1

# Test 3: gpac codecs listing
echo "Test 3: gpac -h codecs"
gpac -h codecs > /dev/null 2>&1

# Test 4: MP4Box version
echo "Test 4: MP4Box -version"
MP4Box -version > /dev/null 2>&1

# Test 5: MP4Box boxes listing
echo "Test 5: MP4Box -boxes"
MP4Box -boxes > /dev/null 2>&1

# Test 6: gpac unit tests (runs internal coverage tests)
echo "Test 6: gpac -unit-tests"
gpac -unit-tests > /dev/null 2>&1

# Test 7: Inspect H264 video file
echo "Test 7: gpac inspect H264"
gpac -i $MEDIA_DIR/enst_video.h264 inspect > /dev/null 2>&1

# Test 8: MP4Box info on AAC
echo "Test 8: MP4Box -info AAC"
MP4Box -info $MEDIA_DIR/enst_audio.aac > /dev/null 2>&1

# Test 9: Create MP4 from H264
echo "Test 9: MP4Box mux H264 to MP4"
MP4Box -add $MEDIA_DIR/enst_video.h264 $TEMP_DIR/test_video.mp4 > /dev/null 2>&1
if [ ! -f $TEMP_DIR/test_video.mp4 ]; then
    echo "FAILED: MP4 file not created"
    exit 1
fi

# Test 10: Verify created MP4
echo "Test 10: MP4Box -info on created MP4"
MP4Box -info $TEMP_DIR/test_video.mp4 > /dev/null 2>&1

# Test 11: Create MP4 from AAC
echo "Test 11: MP4Box mux AAC to MP4"
MP4Box -add $MEDIA_DIR/enst_audio.aac $TEMP_DIR/test_audio.mp4 > /dev/null 2>&1
if [ ! -f $TEMP_DIR/test_audio.mp4 ]; then
    echo "FAILED: Audio MP4 file not created"
    exit 1
fi

# Test 12: Concatenate video and audio
echo "Test 12: MP4Box add audio to video MP4"
MP4Box -add $MEDIA_DIR/enst_audio.aac $TEMP_DIR/test_video.mp4 > /dev/null 2>&1

# Test 13: gpac props help
echo "Test 13: gpac -h props"
gpac -h props > /dev/null 2>&1

# Test 14: gpac links help
echo "Test 14: gpac -h links"
gpac -h links > /dev/null 2>&1

# Test 15: gpac modules help
echo "Test 15: gpac -h modules"
gpac -h modules > /dev/null 2>&1

# Test 16: MP4Box nodes listing
echo "Test 16: MP4Box -nodes"
MP4Box -nodes > /dev/null 2>&1

# Test 17: MP4Box languages listing
echo "Test 17: MP4Box -languages"
MP4Box -languages > /dev/null 2>&1

# Test 18: Inspect AV1 video
echo "Test 18: gpac inspect AV1"
gpac -i $MEDIA_DIR/video.av1 inspect > /dev/null 2>&1

# Test 19: Inspect IVF file
echo "Test 19: gpac inspect IVF"
gpac -i $MEDIA_DIR/enstvid.ivf inspect > /dev/null 2>&1

# Test 20: gpac bin info
echo "Test 20: gpac -h bin"
gpac -h bin > /dev/null 2>&1

# Cleanup
rm -rf $TEMP_DIR

echo "All tests passed!"
exit 0


