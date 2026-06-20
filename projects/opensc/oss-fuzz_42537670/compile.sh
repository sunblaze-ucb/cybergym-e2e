#!/usr/bin/env bash

export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++
export FUZZING_ENGINE=libfuzzer
export SANITIZER=address
export HWASAN_OPTIONS=random_tags=0
export UBSAN_OPTIONS=silence_unsigned_overflow=1
export DFSAN_OPTIONS=warn_unimplemented=0

cd $SRC/opensc
compile
