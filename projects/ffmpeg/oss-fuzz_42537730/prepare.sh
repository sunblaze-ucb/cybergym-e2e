#!/usr/bin/env bash

# Reusing CyberGym Image

# --- neutralise ffmpeg FATE sample fetch (agent phase has no rsync) ---
# fate-suite is used ONLY to build *_seed_corpus.zip; the fuzzer binaries do not
# depend on it, and PoC reproduction runs a single input. rsync:// cannot cross
# the agent-phase proxy, so make the fetch and the corpus steps non-fatal.
for BS in "$SRC/build.sh" "$SRC/ffmpeg/tools/fuzzers/build.sh"; do
  [ -f "$BS" ] || continue
  sed -i -E 's#^(make fate-rsync .*)$#\1 || true#'                     "$BS"
  sed -i -E 's#^(rsync -av rsync://.*)$#\1 || true#'                   "$BS"
  sed -i -E 's#^rm \$\(find (fate-suite|ffv1testset)#rm -f $(find \1#' "$BS"
  sed -i -E 's#^(zip -r .*)$#\1 || true#'                              "$BS"
done
mkdir -p "$SRC/ffmpeg/fate-suite" "$SRC/ffmpeg/ffv1testset"
