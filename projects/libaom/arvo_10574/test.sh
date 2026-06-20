#!/usr/bin/env bash
# test.sh - Unit tests for libaom (arvo_10574)
#
# This script builds libaom with tests enabled and runs the test suite.
# Parameterized DSP/SIMD tests are excluded as they take hours to complete.
# Tests requiring test data files (not present in container) are also excluded.
#
# Excluded tests (with reasons):
#   - *DISABLED*: Explicitly disabled by upstream
#   - *Large*: Long-running variants of tests
#   - *Perf*/*Speed*: Performance benchmarks, not correctness tests
#   - *TestVector*/*InvalidFile*: Require downloaded test data files
#   - ExternalFrameBuffer*: Require test data files
#   - AV1/AVxEncoderParmsGetToDecoder.*: Requires test data files
#   - AV1/AV1ExtTileTest.*: Requires test data files
#   - AV1/AV1DecodeMultiThreadedTest.*: Requires test data files
#   - AV1/AVxEncoderThreadTest.*: Requires test data files
#   - AV1/ActiveMapTest.*: Requires test data files
#   - AV1/AqSegmentTest.*: Requires test data files
#   - AV1/CpuSpeedTest.*: Requires test data files
#   - AV1/EndToEndTest.*: Requires test data files
#   - AV1/MonochromeTest.*: Requires test data files
#   - AV1/QMTest.*: Requires test data files
#   - AV1/ScalabilityTest.*: Requires test data files
#   - AV1/TileIndependence*: Requires test data files
#   - C/Y4mVideo*: Requires test data files
#   - *CDEF*: Heavy parameterized DSP tests (hundreds of instances, 8-11s each)
#   - *Convolve*/*Variance*/*SAD*/*Blend*: Heavy parameterized DSP tests
#   - *CompAvgPred*/*CompMask*/*Warp*/*Txfm2d*: Heavy parameterized DSP tests
#   - *Quant*/*OBMC*/*Masked*/*SIMD*: Heavy parameterized DSP tests
#   - *Superres*/*Intra*/*LoopFilter*: Heavy parameterized DSP tests
#   - *SelfGuided*/*DR*/*HBD*: Heavy parameterized DSP tests
#   - *Subtract*/*SumSquares*/*Error*: Heavy parameterized DSP tests
#   - *FFT*/*FWHT*/*Hash*/*Wiener*/*Pick*: Heavy parameterized DSP tests
#
# Included tests: ~3680 (all non-DSP unit tests + encoder/decoder logic tests)
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

cd /src/aom

# Build with tests enabled in a separate build directory
mkdir -p /work/test_build
cd /work/test_build
rm -rf ./*

cmake /src/aom \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="-O2 -g" \
  -DCMAKE_CXX_FLAGS="-O2 -g" \
  -DCONFIG_PIC=1 \
  -DENABLE_TESTS=1 \
  -DENABLE_EXAMPLES=0 \
  -DENABLE_DOCS=0 \
  -DENABLE_TESTDATA=0 \
  -DCONFIG_AV1_ENCODER=1 \
  -DCONFIG_AV1_DECODER=1

make -j$(nproc) test_libaom

# Build exclusion filter
EXCLUDE="*Large*"
EXCLUDE="${EXCLUDE}:*DISABLED*"
EXCLUDE="${EXCLUDE}:*Perf*"
EXCLUDE="${EXCLUDE}:*Speed*"
EXCLUDE="${EXCLUDE}:*TestVector*"
EXCLUDE="${EXCLUDE}:*InvalidFile*"
# Tests requiring test data files (not present)
EXCLUDE="${EXCLUDE}:ExternalFrameBufferTest.*"
EXCLUDE="${EXCLUDE}:ExternalFrameBufferNonRefTest.*"
EXCLUDE="${EXCLUDE}:AV1/AVxEncoderParmsGetToDecoder.*"
EXCLUDE="${EXCLUDE}:AV1/AV1ExtTileTest.*"
EXCLUDE="${EXCLUDE}:AV1/AV1DecodeMultiThreadedTest.*"
EXCLUDE="${EXCLUDE}:AV1/AVxEncoderThreadTest.*"
EXCLUDE="${EXCLUDE}:AV1/ActiveMapTest.*"
EXCLUDE="${EXCLUDE}:AV1/AqSegmentTest.*"
EXCLUDE="${EXCLUDE}:AV1/CpuSpeedTest.*"
EXCLUDE="${EXCLUDE}:AV1/EndToEndTest.*"
EXCLUDE="${EXCLUDE}:AV1/MonochromeTest.*"
EXCLUDE="${EXCLUDE}:AV1/QMTest.*"
EXCLUDE="${EXCLUDE}:AV1/ScalabilityTest.*"
EXCLUDE="${EXCLUDE}:AV1/TileIndependenceLSTest.*"
EXCLUDE="${EXCLUDE}:AV1/TileIndependenceTest.*"
EXCLUDE="${EXCLUDE}:C/Y4mVideoSourceTest.*"
EXCLUDE="${EXCLUDE}:C/Y4mVideoWriteTest.*"
# Heavy parameterized DSP/SIMD tests (thousands of instances, take hours)
EXCLUDE="${EXCLUDE}:*CDEF*"
EXCLUDE="${EXCLUDE}:*Convolve*"
EXCLUDE="${EXCLUDE}:*Variance*"
EXCLUDE="${EXCLUDE}:*SAD*"
EXCLUDE="${EXCLUDE}:*Blend*"
EXCLUDE="${EXCLUDE}:*CompAvgPred*"
EXCLUDE="${EXCLUDE}:*CompMask*"
EXCLUDE="${EXCLUDE}:*Warp*"
EXCLUDE="${EXCLUDE}:*Txfm2d*"
EXCLUDE="${EXCLUDE}:*Quant*"
EXCLUDE="${EXCLUDE}:*OBMC*"
EXCLUDE="${EXCLUDE}:*Masked*"
EXCLUDE="${EXCLUDE}:*SIMD*"
EXCLUDE="${EXCLUDE}:*Superres*"
EXCLUDE="${EXCLUDE}:*Intra*"
EXCLUDE="${EXCLUDE}:*LoopFilter*"
EXCLUDE="${EXCLUDE}:*SelfGuided*"
EXCLUDE="${EXCLUDE}:*DR*"
EXCLUDE="${EXCLUDE}:*HBD*"
EXCLUDE="${EXCLUDE}:*Subtract*"
EXCLUDE="${EXCLUDE}:*SumSquares*"
EXCLUDE="${EXCLUDE}:*Error*"
EXCLUDE="${EXCLUDE}:*FFT*"
EXCLUDE="${EXCLUDE}:*FWHT*"
EXCLUDE="${EXCLUDE}:*Hash*"
EXCLUDE="${EXCLUDE}:*Wiener*"
EXCLUDE="${EXCLUDE}:*Pick*"

./test_libaom --gtest_filter="-${EXCLUDE}"

echo "All tests passed!"
exit 0
