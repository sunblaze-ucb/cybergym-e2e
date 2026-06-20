#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# The base-builder image uses clang 22 which optimizes memcpy as a builtin,
# bypassing ASAN's interceptor. This prevents the negative-size-param crash
# from being detected. We patch build.sh to add -fno-builtin-memcpy and
# -fno-builtin-memmove so ASAN can intercept the memcpy calls.

if [ -f "$SRC/build.sh" ]; then
    # Add -fno-builtin flags to ensure ASAN intercepts memcpy/memmove
    sed -i '1a export CFLAGS="$CFLAGS -fno-builtin-memcpy -fno-builtin-memmove"\nexport CXXFLAGS="$CXXFLAGS -fno-builtin-memcpy -fno-builtin-memmove"' "$SRC/build.sh"
fi
