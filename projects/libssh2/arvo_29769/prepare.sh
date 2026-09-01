#!/usr/bin/env bash
set -euo pipefail

# Add any additional dependency installation commands here

# --- libssh2 build deps: apt-get appears BOTH in tests/ossfuzz/ossfuzz.sh and in
#     the top-level build.sh. Install the packages here (they are needed to
#     compile, not test-only) and neutralise every apt call in the build path. ---
apt-get update
apt-get install -y autoconf automake libtool m4 pkg-config libssl-dev zlib1g-dev
for BS in "$SRC/build.sh" "$SRC/libssh2/tests/ossfuzz/ossfuzz.sh"; do
  [ -f "$BS" ] && sed -i -E 's#^([[:space:]]*)apt-get .*$#\1true#' "$BS" || true
done
