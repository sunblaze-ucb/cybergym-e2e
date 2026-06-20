#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Install autotools required by hunspell's build system

apt-get update -qq && apt-get install -y -qq autoconf automake libtool gettext autopoint gcc g++ gcc-multilib g++-multilib >/dev/null 2>&1

# Create build.sh that calls hunspell's oss-fuzz-build.sh
cat > $SRC/build.sh << 'EOF'
#!/bin/bash
$SRC/hunspell/oss-fuzz-build.sh
EOF
chmod +x $SRC/build.sh
