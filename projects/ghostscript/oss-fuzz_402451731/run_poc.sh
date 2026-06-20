#!/usr/bin/env bash
export FUZZING_ENGINE=libfuzzer
export SANITIZER=address
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++

POC_PATH="${1:-$SRC/poc.bin}"
/out/gs_device_tiffsep1_fuzzer "$POC_PATH"