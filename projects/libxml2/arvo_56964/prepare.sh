#!/usr/bin/env bash
set -euo pipefail

# Add any additional dependency installation commands here

apt-get update && \
    case "$ARCHITECTURE" in \
        'linux/arm64') EXTRA_PACKAGES='' ;; \
        *)             EXTRA_PACKAGES='zlib1g-dev:i386 liblzma-dev:i386' ;; \
    esac && \
    apt-get install -y --no-install-recommends \
        make autoconf libtool pkg-config \
        zlib1g-dev liblzma-dev \
        $EXTRA_PACKAGES

curl -LO http://mirrors.kernel.org/ubuntu/pool/main/a/automake-1.16/automake_1.16.5-1.3_all.deb && \
    apt install ./automake_1.16.5-1.3_all.deb
