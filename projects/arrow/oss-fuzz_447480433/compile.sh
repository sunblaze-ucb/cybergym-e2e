#!/usr/bin/env bash
source /deps/arrow_env_ok.sh || true  # arrow deps prefetched in prepare.sh
export FUZZING_ENGINE=libfuzzer
export SANITIZER=address
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++

cd $SRC/arrow
compile
