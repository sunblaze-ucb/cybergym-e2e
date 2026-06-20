#!/usr/bin/env bash

export FUZZING_LANGUAGE=c++
export FUZZING_ENGINE=libfuzzer
export SANITIZER=undefined
export ARCHITECTURE=x86_64
export HWASAN_OPTIONS=random_tags=0
export UBSAN_OPTIONS=silence_unsigned_overflow=1
export DFSAN_OPTIONS=warn_unimplemented=0

POC_PATH="${1:-$SRC/poc.bin}"
/out/uri_parsew_fuzzer "$POC_PATH"
