#!/usr/bin/env bash
export FUZZING_ENGINE=libfuzzer
export SANITIZER=memory
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++

POC_PATH="${1:-$SRC/poc.bin}"
/out/ffmpeg_dem_FLAC_fuzzer "$POC_PATH"