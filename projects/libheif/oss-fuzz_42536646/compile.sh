#!/usr/bin/env bash

export FUZZING_LANGUAGE=c++
export FUZZING_ENGINE=honggfuzz
export SANITIZER=address
export ARCHITECTURE=x86_64
export HWASAN_OPTIONS=random_tags=0
export UBSAN_OPTIONS=silence_unsigned_overflow=1
export DFSAN_OPTIONS=warn_unimplemented=0

cd $SRC/libheif
compile
