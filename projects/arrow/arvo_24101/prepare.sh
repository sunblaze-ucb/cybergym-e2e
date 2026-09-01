#!/usr/bin/env bash

# Prepare.sh for arrow
# Install missing dependencies and downgrade clang to version 11
# (the Arrow code from 2020 doesn't compile with clang 22 due to
# flatbuffers vendored header issues with deleted operator=)

set -ex

# Install ninja-build, boost, and clang-11 with libc++
apt-get update -y
apt-get install -y ninja-build libboost-all-dev clang-11 libc++-11-dev libc++abi-11-dev

# Override clang symlinks to point to clang-11
# This ensures the build uses the compatible compiler version
ln -sf /usr/bin/clang-11 /usr/local/bin/clang
ln -sf /usr/bin/clang++-11 /usr/local/bin/clang++

# Create build.sh that the compile function sources
cat > /src/build.sh << 'BUILDEOF'

set -ex
ARROW=${SRC}/arrow/cpp
cd ${WORK}
export ASAN_OPTIONS="detect_leaks=0"
cmake ${ARROW} -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DARROW_DEPENDENCY_SOURCE=BUNDLED \
    -DBOOST_SOURCE=SYSTEM \
    -DCMAKE_C_FLAGS="${CFLAGS}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
    -DARROW_SIMD_LEVEL=NONE \
    -DARROW_EXTRA_ERROR_CONTEXT=off \
    -DARROW_JEMALLOC=off \
    -DARROW_MIMALLOC=off \
    -DARROW_FILESYSTEM=off \
    -DARROW_PARQUET=off \
    -DARROW_BUILD_SHARED=off \
    -DARROW_BUILD_STATIC=on \
    -DARROW_BUILD_TESTS=off \
    -DARROW_BUILD_INTEGRATION=off \
    -DARROW_BUILD_BENCHMARKS=off \
    -DARROW_BUILD_EXAMPLES=off \
    -DARROW_BUILD_UTILITIES=off \
    -DARROW_TEST_LINKAGE=static \
    -DPARQUET_BUILD_EXAMPLES=off \
    -DPARQUET_BUILD_EXECUTABLES=off \
    -DPARQUET_REQUIRE_ENCRYPTION=off \
    -DARROW_WITH_BROTLI=off \
    -DARROW_WITH_BZ2=off \
    -DARROW_WITH_LZ4=off \
    -DARROW_WITH_SNAPPY=off \
    -DARROW_WITH_ZLIB=off \
    -DARROW_WITH_ZSTD=off \
    -DARROW_USE_GLOG=off \
    -DARROW_USE_ASAN=off \
    -DARROW_USE_UBSAN=off \
    -DARROW_USE_TSAN=off \
    -DARROW_FUZZING=on
cmake --build .
cp -a release/* ${OUT}
${ARROW}/build-support/fuzzing/generate_corpuses.sh ${OUT} || true
BUILDEOF

chmod +x /src/build.sh

echo "prepare.sh completed successfully"

# --- prefetch arrow thirdparty tarballs so the agent phase builds offline ---
# Upstream ships an offline-build downloader; it needs wget, and one of its URLs
# (c-ares) has rotted, so run a failure-tolerant copy written BESIDE the original
# (the script reads versions.txt relative to ${BASH_SOURCE[0]}).
if [ -f "$SRC/arrow/cpp/thirdparty/download_dependencies.sh" ]; then
  apt-get install -y -qq wget
  mkdir -p /deps/arrow
  TP="$SRC/arrow/cpp/thirdparty"
  set +e
  sed 's/exit 1)/true)/' "$TP/download_dependencies.sh" > "$TP/dl_tolerant.sh"
  bash "$TP/dl_tolerant.sh" /deps/arrow > /deps/arrow_env.sh 2>/deps/arrow_err.txt
  set -e
  # keep only exports whose tarball actually downloaded
  awk '/^export /{split($2,a,"="); if (system("test -f " a[2])==0) print}' \
      /deps/arrow_env.sh > /deps/arrow_env_ok.sh
  echo "arrow prefetched deps: $(wc -l < /deps/arrow_env_ok.sh)"
fi

# --- prefetch git deps used for corpus generation ---
# arrow's build clones pandas to build a parquet seed corpus; mirror it so the
# agent phase resolves the clone locally.
mkdir -p /deps/git/github.com/pandas-dev
if [ ! -d /deps/git/github.com/pandas-dev/pandas ]; then
  git clone --mirror https://github.com/pandas-dev/pandas.git /deps/git/github.com/pandas-dev/pandas \
    || echo "WARN: could not mirror pandas"
fi
[ -d /deps/git/github.com/pandas-dev/pandas ] && \
  ln -sfn /deps/git/github.com/pandas-dev/pandas /deps/git/github.com/pandas-dev/pandas.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always
