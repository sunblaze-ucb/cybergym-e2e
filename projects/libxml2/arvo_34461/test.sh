#!/usr/bin/env bash
set -euo pipefail

cd ${SRC:-/src}/libxml2

./autogen.sh
./configure --with-python=no
make -j"$(nproc)"

make check -j$(nproc)

exit 0
