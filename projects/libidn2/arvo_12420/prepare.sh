#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y autoconf automake gettext libtool autopoint pkg-config gengetopt gperf
