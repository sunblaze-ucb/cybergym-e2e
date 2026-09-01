#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update && apt-get install -y pkg-config libncurses5-dev libssl-dev python3-pip libglib2.0-dev
pip3 install -U meson ninja

# --- prefetch meson subprojects (wrap / wrapdb), recursively ---
# `meson subprojects download` only fetches TOP-LEVEL wraps; a downloaded
# subproject (e.g. glib) has its own wraps that meson would fetch at configure
# time. Iterate a few levels so nested wraps land during the install phase too.
python3 -m pip install --quiet --upgrade meson ninja 2>/dev/null || true
for ROUND in 1 2 3; do
  for SUB in $(find "$SRC" -maxdepth 8 -type d -name subprojects 2>/dev/null); do
    D=$(dirname "$SUB")
    [ -f "$D/meson.build" ] || continue
    ( cd "$D" && meson subprojects download ) >/dev/null 2>&1 \
      || echo "WARN: meson subprojects download failed in $D (round $ROUND)"
  done
done

# --- prefetch git deps (mirror locally, then rewrite https->file) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/irssi-import/themes)
( git clone --mirror https://github.com/irssi-import/themes.git /deps/git/github.com/irssi-import/themes 2>/dev/null || git clone --mirror https://github.com/irssi-import/themes /deps/git/github.com/irssi-import/themes ) || echo 'WARN: could not mirror https://github.com/irssi-import/themes'
[ -d /deps/git/github.com/irssi-import/themes ] && ln -sfn /deps/git/github.com/irssi-import/themes /deps/git/github.com/irssi-import/themes.git || true
mkdir -p $(dirname /deps/git/github.com/irssi/irssi-fuzzing-corpora)
( git clone --mirror https://github.com/irssi/irssi-fuzzing-corpora.git /deps/git/github.com/irssi/irssi-fuzzing-corpora 2>/dev/null || git clone --mirror https://github.com/irssi/irssi-fuzzing-corpora /deps/git/github.com/irssi/irssi-fuzzing-corpora ) || echo 'WARN: could not mirror https://github.com/irssi/irssi-fuzzing-corpora'
[ -d /deps/git/github.com/irssi/irssi-fuzzing-corpora ] && ln -sfn /deps/git/github.com/irssi/irssi-fuzzing-corpora /deps/git/github.com/irssi/irssi-fuzzing-corpora.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
