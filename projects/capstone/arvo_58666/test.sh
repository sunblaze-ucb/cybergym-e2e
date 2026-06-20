#!/usr/bin/env bash
set -e

apt-get update -y
apt-get install -y libyaml-dev cmake python3
apt-get install -y libcmocka-dev
apt-get install -y pkg-config

cd $SRC/capstonenext

rm -rf build
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCAPSTONE_BUILD_CSTEST=ON
cmake --build build --config Debug
cmake --install build

cd suite/cstest
make
make cstest
