#!/usr/bin/env bash
# Nothing to do!

# --- prefetch opus DNN model so the agent phase needs no network ---
# ffmpeg bundles opus; opus/autogen.sh runs dnn/download_model.sh, which wgets
# a model tarball from media.xiph.org unless it is already present in $SRC/opus.
if [ -f "$SRC/opus/autogen.sh" ]; then
  apt-get install -y -qq wget
  SHA=$(grep -oE '[0-9a-f]{64}' "$SRC/opus/autogen.sh" | head -1)
  if [ -n "$SHA" ] && [ ! -f "$SRC/opus/opus_data-$SHA.tar.gz" ]; then
    ( cd "$SRC/opus" && wget -q -O "opus_data-$SHA.tar.gz" \
        "https://media.xiph.org/opus/models/opus_data-$SHA.tar.gz" ) \
      || echo "WARN: could not prefetch opus model"
  fi
fi

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
