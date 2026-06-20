#!/usr/bin/env bash
export FUZZING_ENGINE=honggfuzz
export SANITIZER=address
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++

POC_PATH="${1:-$SRC/poc.bin}"
/out/libarchive_fuzzer "$POC_PATH"