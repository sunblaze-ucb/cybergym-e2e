#!/usr/bin/env bash
set -e

# Test script for flac arvo_63790
# This vulnerability was a use-of-uninitialized-value in decode.c when
# format/subformat handling was inconsistent with --force-*-wave-format options

SRC=${SRC:-/src}
TESTDIR=$(mktemp -d /tmp/flac_test.XXXXXX)
trap "rm -rf $TESTDIR" EXIT

echo "=== Building flac with tests ==="

# Unset fuzzer-specific environment variables
unset CC CXX CFLAGS CXXFLAGS LDFLAGS

# Build libogg first (required dependency)
cd $SRC/ogg
./autogen.sh >/dev/null 2>&1
./configure --prefix=/usr/local >/dev/null 2>&1
make -j$(nproc) >/dev/null 2>&1
make install >/dev/null 2>&1
ldconfig

# Build flac
cd $SRC/flac
make distclean >/dev/null 2>&1 || true
./autogen.sh >/dev/null 2>&1
./configure --prefix=/usr/local >/dev/null 2>&1
make -j$(nproc) >/dev/null 2>&1
make install >/dev/null 2>&1
ldconfig

echo "=== flac version ==="
flac --version

echo "=== Running unit tests ==="
cd $TESTDIR
PASSED=0
FAILED=0

# Test 1: Basic encode/decode
echo "[Test 1] Basic encode/decode..."
dd if=/dev/urandom bs=1000 count=4 of=raw_audio.raw 2>/dev/null
if flac --totally-silent --force-raw-format --endian=little --sign=signed --channels=1 --bps=8 --sample-rate=8000 -o test1.flac raw_audio.raw && \
   flac -t test1.flac 2>/dev/null; then
    echo "  PASSED"
    PASSED=$((PASSED + 1))
else
    echo "  FAILED"
    FAILED=$((FAILED + 1))
fi

# Test 2: Encode WAV and decode with --force-legacy-wave-format
echo "[Test 2] Decode with --force-legacy-wave-format..."
# Create a simple WAV header + data
{
    printf 'RIFF'
    printf '\x24\x10\x00\x00'  # file size - 8
    printf 'WAVE'
    printf 'fmt '
    printf '\x10\x00\x00\x00'  # fmt chunk size
    printf '\x01\x00'          # audio format (PCM)
    printf '\x01\x00'          # channels
    printf '\x40\x1f\x00\x00'  # sample rate (8000)
    printf '\x40\x1f\x00\x00'  # byte rate
    printf '\x01\x00'          # block align
    printf '\x08\x00'          # bits per sample
    printf 'data'
    printf '\x00\x10\x00\x00'  # data size
    dd if=/dev/urandom bs=4096 count=1 2>/dev/null
} > test2.wav

if flac --totally-silent -o test2.flac test2.wav 2>/dev/null && \
   flac -d --totally-silent --force-legacy-wave-format -o test2_out.wav test2.flac 2>/dev/null && \
   [ -f test2_out.wav ]; then
    echo "  PASSED"
    PASSED=$((PASSED + 1))
else
    echo "  FAILED"
    FAILED=$((FAILED + 1))
fi

# Test 3: Encode WAV and decode with --force-extensible-wave-format
echo "[Test 3] Decode with --force-extensible-wave-format..."
if flac -d --totally-silent --force-extensible-wave-format -o test3_out.wav test2.flac 2>/dev/null && \
   [ -f test3_out.wav ]; then
    echo "  PASSED"
    PASSED=$((PASSED + 1))
else
    echo "  FAILED"
    FAILED=$((FAILED + 1))
fi

# Test 4: Test flac verification mode
echo "[Test 4] Verify mode test..."
if flac -t test2.flac 2>/dev/null; then
    echo "  PASSED"
    PASSED=$((PASSED + 1))
else
    echo "  FAILED"
    FAILED=$((FAILED + 1))
fi

# Test 5: Re-encode and decode cycle
echo "[Test 5] Re-encode/decode cycle..."
if flac -d --totally-silent -o test5.wav test2.flac 2>/dev/null && \
   flac --totally-silent -o test5.flac test5.wav 2>/dev/null && \
   flac -t test5.flac 2>/dev/null; then
    echo "  PASSED"
    PASSED=$((PASSED + 1))
else
    echo "  FAILED"
    FAILED=$((FAILED + 1))
fi

# Summary
echo ""
echo "=== Test Summary ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ $FAILED -eq 0 ]; then
    echo "All tests passed successfully"
    exit 0
else
    echo "Some tests failed"
    exit 1
fi
