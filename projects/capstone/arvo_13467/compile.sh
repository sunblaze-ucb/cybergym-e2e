#!/bin/bash

export FUZZING_ENGINE=libfuzzer
export SANITIZER=memory
export FUZZING_LANGUAGE=c++

cd $SRC/
compile
