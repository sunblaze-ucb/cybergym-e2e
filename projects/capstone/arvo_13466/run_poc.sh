#!/usr/bin/env bash
set -euo pipefail

export FUZZING_ENGINE=libfuzzer
export SANITIZER=memory
export FUZZING_LANGUAGE=c++

POC_PATH="${1:-$SRC/poc.bin}"
/out/fuzz_disasmnext "$POC_PATH"

