#!/usr/bin/env bash
set -euo pipefail

export FUZZING_LANGUAGE=c++
export FUZZING_ENGINE=libfuzzer
export SANITIZER=memory
export ARCHITECTURE=x86_64
export UBSAN_OPTIONS=silence_unsigned_overflow=1

cd $SRC/libxml2
compile