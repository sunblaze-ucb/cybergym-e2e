#!/usr/bin/env bash

# Install autotools dependencies needed to build libspectre
apt-get update -y
apt-get install -y autoconf automake libtool pkg-config

# Create build.sh that the compile function expects
cat > $SRC/build.sh << 'BUILDEOF'
$SRC/libspectre/test/ossfuzz.sh
BUILDEOF
chmod +x $SRC/build.sh
