#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y make autoconf automake libtool pkg-config libcunit1 libcunit1-doc libcunit1-dev