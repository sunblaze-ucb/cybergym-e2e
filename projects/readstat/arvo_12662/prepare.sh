#!/usr/bin/env bash
set -euo pipefail

# Install autotools required by autogen.sh
apt-get update && apt-get install -y make autoconf automake gettext libtool zip zlib1g-dev
