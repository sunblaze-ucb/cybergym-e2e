#!/usr/bin/env bash
set -e

true  # apt lists fetched in prepare.sh
cp -n /deps/debs/*.deb /var/cache/apt/archives/ 2>/dev/null || true; apt-get install -y --no-download libyaml-dev cmake python3  # pre-downloaded in prepare.sh
cp -n /deps/debs/*.deb /var/cache/apt/archives/ 2>/dev/null || true; apt-get install -y --no-download libcmocka-dev  # pre-downloaded in prepare.sh
cp -n /deps/debs/*.deb /var/cache/apt/archives/ 2>/dev/null || true; apt-get install -y --no-download pkg-config  # pre-downloaded in prepare.sh

cd $SRC/capstonenext

rm -rf build
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCAPSTONE_BUILD_CSTEST=ON
cmake --build build --config Debug
cmake --install build

cd suite/cstest
make
make cstest
