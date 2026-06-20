#!/usr/bin/env bash
export FUZZING_ENGINE=libfuzzer
export SANITIZER=address
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c

POC_PATH="${1:-$SRC/poc.bin}"
/out/wasm_mutator_fuzz_loader "$POC_PATH"