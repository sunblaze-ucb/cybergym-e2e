#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update && apt-get install -y autoconf automake autopoint libtool
