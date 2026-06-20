#!/usr/bin/env bash
export FUZZING_ENGINE=honggfuzz
export SANITIZER=address
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c

cd $SRC/quickjs
compile