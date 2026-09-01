#!/usr/bin/env bash
# Nothing to do!

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
