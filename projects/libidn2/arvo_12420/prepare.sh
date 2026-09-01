#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y autoconf automake gettext libtool autopoint pkg-config gengetopt gperf

# --- skip gnulib .po download (translations are irrelevant to fuzzing and the
#     agent phase cannot reach translationproject.org over rsync) ---
if [ -f "$SRC/build.sh" ]; then
  sed -i -E 's#^(\./bootstrap)([[:space:]]*)$#\1 --skip-po\2#' "$SRC/build.sh"
fi
