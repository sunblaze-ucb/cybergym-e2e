#!/usr/bin/env bash
# Nothing to do!

# --- prefetch so compile.sh/test.sh need no network in the agent phase ---
apt-get update
mkdir -p /deps/wheels
pip3 download -d /deps/wheels meson ninja
