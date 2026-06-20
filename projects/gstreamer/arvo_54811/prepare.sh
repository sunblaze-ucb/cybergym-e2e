#!/usr/bin/env bash

# Install build dependencies missing from the base-builder image
apt-get update -qq
apt-get install -y -qq \
    autoconf automake libtool gettext \
    bison flex nasm \
    pkg-config ninja-build \
    2>/dev/null

# Install meson (same version as arvo image)
pip3 install meson==0.63.2 2>/dev/null

# Create the build.sh expected by compile (which calls the `compile` function)
cat > /src/build.sh << 'BUILDEOF'
#!/bin/bash
$SRC/gstreamer/ci/fuzzing/build-oss-fuzz.sh
BUILDEOF
chmod +x /src/build.sh

# Avoid GStreamer plugin scanner fork warning ("not found" in output)
# GST_REGISTRY_FORK=no makes GStreamer scan plugins in-process instead of
# spawning the external gst-plugin-scanner binary
cat > /etc/profile.d/gstreamer-env.sh << 'ENVEOF'
export GST_REGISTRY_FORK=no
ENVEOF
