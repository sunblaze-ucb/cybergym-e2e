#!/usr/bin/env bash
set -euo pipefail

# Install build dependencies for p11-kit
apt-get update
apt-get install -y autoconf automake libtool gettext autopoint pkg-config libffi-dev libtasn1-6-dev libtasn1-bin
