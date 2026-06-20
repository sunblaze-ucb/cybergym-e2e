#!/bin/bash

export FUZZING_ENGINE=afl
export SANITIZER=address
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++


cd $SRC/curl_fuzzer
compile