#!/usr/bin/env bash
# test.sh - ALL unit tests for librawspeed (arvo_3265)
#
# This script builds and runs the COMPLETE test suite for librawspeed.
# The project's build.sh uses -DBUILD_TESTING=OFF and deletes the build dir,
# so we do a separate cmake build with testing enabled.
#
# Key issues solved:
#   - CMakeLists.txt sets -Werror via set_directory_properties which overrides
#     env-level -Wno-error. We use a compiler wrapper to strip -Werror.
#   - The test code uses googletest 1.8.0 API (std::tr1), not compatible with
#     newer versions. We let cmake download the correct version.
#   - Out-of-source build is required.
#   - cmake 3.16 (apt) is needed; the bundled cmake 3.29 has foreach() compat issues.
#
# Total tests: 14
# Included: 14
# Excluded: 0
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

echo "=== Installing test dependencies ==="
apt-get update -qq 2>/dev/null
apt-get install -y -qq cmake 2>&1 | tail -1

# Create compiler wrappers that strip -Werror
# (CMakeLists.txt forces -Werror via set_directory_properties COMPILE_OPTIONS)
cat > /tmp/cc-wrap << 'EOF'
#!/usr/bin/env python3
import sys, os
args = [a for a in sys.argv[1:] if a != '-Werror']
os.execvp('/usr/local/bin/clang', ['/usr/local/bin/clang'] + args)
EOF

cat > /tmp/cxx-wrap << 'EOF'
#!/usr/bin/env python3
import sys, os
args = [a for a in sys.argv[1:] if a != '-Werror']
os.execvp('/usr/local/bin/clang++', ['/usr/local/bin/clang++'] + args)
EOF
chmod +x /tmp/cc-wrap /tmp/cxx-wrap

export CC=/tmp/cc-wrap
export CXX=/tmp/cxx-wrap

echo "=== Configuring test build ==="
rm -rf /tmp/testbuild
mkdir -p /tmp/testbuild
cd /tmp/testbuild

# Use cmake 3.16 from apt (avoids foreach(IN ...) compat issue in cmake 3.29)
# Download googletest 1.8.0 (test code uses std::tr1 API, incompatible with 1.10+)
/usr/bin/cmake -G"Unix Makefiles" \
  -DBINARY_PACKAGE_BUILD=ON \
  -DWITH_PTHREADS=OFF -DWITH_OPENMP=OFF \
  -DWITH_PUGIXML=OFF -DUSE_XMLLINT=OFF -DWITH_JPEG=OFF -DWITH_ZLIB=OFF \
  -DBUILD_TESTING=ON -DBUILD_TOOLS=OFF -DBUILD_BENCHMARKING=OFF \
  -DBUILD_FUZZERS=OFF \
  -DALLOW_DOWNLOADING_GOOGLETEST=ON \
  -DGOOGLETEST_PATH=/nonexistent \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  ${SRC:-/src}/librawspeed/

echo "=== Building tests ==="
make -j$(nproc)

echo "=== Running tests ==="
ctest --output-on-failure

echo "All tests passed!"
exit 0
