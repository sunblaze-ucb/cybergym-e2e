#!/usr/bin/env bash
set -euo pipefail

# Create missing aflHarness.h header
cat > $SRC/h3/src/apps/applib/include/aflHarness.h << 'EOF'
#ifndef AFL_HARNESS_H
#define AFL_HARNESS_H

// Using libAFLDriver.a for AFL harness
// Define the macro as empty since libAFLDriver provides main()
#define AFL_HARNESS_MAIN(size) 

#endif
EOF
