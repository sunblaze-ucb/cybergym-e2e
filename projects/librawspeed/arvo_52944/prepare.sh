#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Nothing to do!

# --- prefetch googletest so test.sh needs no network in the agent phase ---
# test.sh configures with ALLOW_DOWNLOADING_GOOGLETEST=ON and no GOOGLETEST_PATH,
# so cmake fetches release-1.8.1 from github at test time. Fetch it here instead;
# /deps is outside /src, so it survives validate.py's restore_src().
if [ ! -d /deps/googletest ]; then
  mkdir -p /deps
  git clone --depth 1 --branch release-1.8.1 https://github.com/google/googletest /deps/googletest \
    || echo "WARN: could not prefetch googletest"
fi
