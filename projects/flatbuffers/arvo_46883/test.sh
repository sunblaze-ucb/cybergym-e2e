#!/usr/bin/env bash
  
cd $SRC/flatbuffers

env -u CFLAGS -u CXXFLAGS -u LDFLAGS   cmake -G "Unix Makefiles"  -DFLATBUFFERS_BUILD_TESTS=ON     -DFLATBUFFERS_BUILD_FLATC=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-Wno-error=deprecated-builtins"

make -j"$(nproc || echo 4)"

./flattests
