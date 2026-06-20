#!/usr/bin/env bash
export FUZZING_ENGINE=libfuzzer
export SANITIZER=memory
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++

# Wipe stale meson build dirs (with build.ninja) to avoid MSan conflicts
for d in $SRC/*/build; do [ -f "$d/build.ninja" ] && rm -rf "$d"; done

cd $SRC/ffmpeg
compile