#!/usr/bin/env bash
export FUZZING_ENGINE=libfuzzer
export SANITIZER=undefined
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++

cd $SRC/libwebp
compile