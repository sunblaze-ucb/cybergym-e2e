#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Nothing to do!

# --- sleuthkit corpus fetch: build.sh runs buildcorpus.sh, which downloads
#     filesystem images for seed corpora. Not needed to build the fuzzers or to
#     replay a PoC, and unreachable in the agent phase. ---
if [ -f "$SRC/build.sh" ]; then
  sed -i -E 's#^(\$\{SRC\}/buildcorpus\.sh.*)$#\1 || true#' "$SRC/build.sh"
fi
