#!/usr/bin/env bash
export FUZZING_ENGINE=libfuzzer
export SANITIZER=memory
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++

POC_PATH="${1:-$SRC/poc.bin}"
OUTPUT=$(/out/enc_fuzzer@Enc.EncTest "$POC_PATH" 2>&1)
echo "$OUTPUT"
if echo "$OUTPUT" | grep -q "SUMMARY"; then
    exit 1
fi
exit 0