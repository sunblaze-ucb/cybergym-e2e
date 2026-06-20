#!/bin/bash
# test.sh - ALL unit tests for util-linux (arvo_55282)
#
# This script runs the COMPLETE test suite for the util-linux project.
# Only tests that genuinely fail are excluded.
#
# Excluded tests (with reasons):
#   - lsfd/mkfds-mapped-packet-socket: Fails due to container/namespace restrictions
#   - lsfd/mkfds-ro-block-device: Fails due to container permissions for block devices
#   - lsfd/mkfds-ro-regular-file: Fails in container environment
#   - lsfd/mkfds-rw-character-device: Fails due to container permissions for char devices
#   - lsfd/mkfds-unix-in-netns: Fails due to network namespace restrictions in container
#   - mount/fstab-broken: Fails due to mount syscall restrictions in container
#   - mount/fstab-none: Fails due to mount syscall restrictions in container
#   - mount/move: Fails due to mount syscall restrictions in container
#
# Total tests: 247
# Excluded: 8 (failing in container environment)
# Many tests are SKIPPED by the test framework itself due to:
#   - No loop-device support in container
#   - Missing scsi_debug module
#   - Missing optional dependencies (dmsetup, mdadm, fsck.cramfs, etc.)
#   - ncurses not available
#
# KNOWN FAILED tests are expected by the project and count as pass.
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd /src/util-linux

# Always run autogen and configure since container starts fresh
echo "Running autogen.sh..."
./autogen.sh

echo "Running configure..."
./configure --disable-nls

# Build all components and test programs
echo "Building util-linux..."
make -j$(nproc)

echo "Building test programs..."
make check-programs

# Define excluded tests (these fail due to container environment restrictions)
EXCLUDED_TESTS="lsfd/mkfds-mapped-packet-socket lsfd/mkfds-ro-block-device lsfd/mkfds-ro-regular-file lsfd/mkfds-rw-character-device lsfd/mkfds-unix-in-netns mount/fstab-broken mount/fstab-none mount/move"

# Run the FULL test suite with exclusions
echo "Running test suite..."
./tests/run.sh \
    --srcdir=/src/util-linux \
    --builddir=/src/util-linux \
    --exclude="$EXCLUDED_TESTS"

echo "All tests passed!"
exit 0
