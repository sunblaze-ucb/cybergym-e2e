#!/usr/bin/env bash

export FUZZING_LANGUAGE=c++
export FUZZING_ENGINE=libfuzzer
export SANITIZER=memory
export ARCHITECTURE=x86_64
export HWASAN_OPTIONS=random_tags=0
export UBSAN_OPTIONS=silence_unsigned_overflow=1
export DFSAN_OPTIONS=warn_unimplemented=0

# Wipe stale meson build dirs (with build.ninja) to avoid MSan conflicts
# Skip source dirs like libvpx/build which contain configure scripts
for d in $SRC/*/build; do [ -f "$d/build.ninja" ] && rm -rf "$d"; done

cd $SRC/ffmpeg
compile
