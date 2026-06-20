#!/usr/bin/env bash
set -euo pipefail

# Install autoconf, automake, and libtool required by autogen.sh
apt-get update && apt-get install -y autoconf automake libtool
