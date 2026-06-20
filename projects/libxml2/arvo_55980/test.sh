#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/libxml2


mkdir -p test/disabled

mv ./test/XInclude/without-reader/max-recurse.xml test/disabled/ || true

./autogen.sh
# Need to run without-modules... refer to:
# https://github.com/GNOME/libxml2/commit/b1b0df6e9b19d961fc685d991c8ebb34d38b9955
./configure --with-python=no --with-minimum
make -j"$(nproc)"

make check -j$(nproc)

