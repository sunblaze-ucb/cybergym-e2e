#!/usr/bin/env bash
# Nothing to do!

# --- prefetch git deps (mirror locally, then rewrite https->file so the
#     agent phase resolves clones with no network) ---
mkdir -p /deps/git
mkdir -p $(dirname /deps/git/github.com/DaveGamble/cJSON)
( git clone --mirror https://github.com/DaveGamble/cJSON.git /deps/git/github.com/DaveGamble/cJSON 2>/dev/null || git clone --mirror https://github.com/DaveGamble/cJSON /deps/git/github.com/DaveGamble/cJSON ) || echo 'WARN: could not mirror https://github.com/DaveGamble/cJSON'
[ -d /deps/git/github.com/DaveGamble/cJSON ] && ln -sfn /deps/git/github.com/DaveGamble/cJSON /deps/git/github.com/DaveGamble/cJSON.git || true
mkdir -p $(dirname /deps/git/github.com/GoogleChromeLabs/wasm-av1)
( git clone --mirror https://github.com/GoogleChromeLabs/wasm-av1.git /deps/git/github.com/GoogleChromeLabs/wasm-av1 2>/dev/null || git clone --mirror https://github.com/GoogleChromeLabs/wasm-av1 /deps/git/github.com/GoogleChromeLabs/wasm-av1 ) || echo 'WARN: could not mirror https://github.com/GoogleChromeLabs/wasm-av1'
[ -d /deps/git/github.com/GoogleChromeLabs/wasm-av1 ] && ln -sfn /deps/git/github.com/GoogleChromeLabs/wasm-av1 /deps/git/github.com/GoogleChromeLabs/wasm-av1.git || true
mkdir -p $(dirname /deps/git/github.com/MatthiasJReisinger/PolyBenchC-4.2.1)
( git clone --mirror https://github.com/MatthiasJReisinger/PolyBenchC-4.2.1.git /deps/git/github.com/MatthiasJReisinger/PolyBenchC-4.2.1 2>/dev/null || git clone --mirror https://github.com/MatthiasJReisinger/PolyBenchC-4.2.1 /deps/git/github.com/MatthiasJReisinger/PolyBenchC-4.2.1 ) || echo 'WARN: could not mirror https://github.com/MatthiasJReisinger/PolyBenchC-4.2.1'
[ -d /deps/git/github.com/MatthiasJReisinger/PolyBenchC-4.2.1 ] && ln -sfn /deps/git/github.com/MatthiasJReisinger/PolyBenchC-4.2.1 /deps/git/github.com/MatthiasJReisinger/PolyBenchC-4.2.1.git || true
mkdir -p $(dirname /deps/git/github.com/WebAssembly/wabt)
( git clone --mirror https://github.com/WebAssembly/wabt.git /deps/git/github.com/WebAssembly/wabt 2>/dev/null || git clone --mirror https://github.com/WebAssembly/wabt /deps/git/github.com/WebAssembly/wabt ) || echo 'WARN: could not mirror https://github.com/WebAssembly/wabt'
[ -d /deps/git/github.com/WebAssembly/wabt ] && ln -sfn /deps/git/github.com/WebAssembly/wabt /deps/git/github.com/WebAssembly/wabt.git || true
mkdir -p $(dirname /deps/git/github.com/asmjit/asmjit)
( git clone --mirror https://github.com/asmjit/asmjit.git /deps/git/github.com/asmjit/asmjit 2>/dev/null || git clone --mirror https://github.com/asmjit/asmjit /deps/git/github.com/asmjit/asmjit ) || echo 'WARN: could not mirror https://github.com/asmjit/asmjit'
[ -d /deps/git/github.com/asmjit/asmjit ] && ln -sfn /deps/git/github.com/asmjit/asmjit /deps/git/github.com/asmjit/asmjit.git || true
mkdir -p $(dirname /deps/git/github.com/eembc/coremark)
( git clone --mirror https://github.com/eembc/coremark.git /deps/git/github.com/eembc/coremark 2>/dev/null || git clone --mirror https://github.com/eembc/coremark /deps/git/github.com/eembc/coremark ) || echo 'WARN: could not mirror https://github.com/eembc/coremark'
[ -d /deps/git/github.com/eembc/coremark ] && ln -sfn /deps/git/github.com/eembc/coremark /deps/git/github.com/eembc/coremark.git || true
mkdir -p $(dirname /deps/git/github.com/emscripten-core/emsdk)
( git clone --mirror https://github.com/emscripten-core/emsdk.git /deps/git/github.com/emscripten-core/emsdk 2>/dev/null || git clone --mirror https://github.com/emscripten-core/emsdk /deps/git/github.com/emscripten-core/emsdk ) || echo 'WARN: could not mirror https://github.com/emscripten-core/emsdk'
[ -d /deps/git/github.com/emscripten-core/emsdk ] && ln -sfn /deps/git/github.com/emscripten-core/emsdk /deps/git/github.com/emscripten-core/emsdk.git || true
mkdir -p $(dirname /deps/git/github.com/ggerganov/llama.cpp)
( git clone --mirror https://github.com/ggerganov/llama.cpp.git /deps/git/github.com/ggerganov/llama.cpp 2>/dev/null || git clone --mirror https://github.com/ggerganov/llama.cpp /deps/git/github.com/ggerganov/llama.cpp ) || echo 'WARN: could not mirror https://github.com/ggerganov/llama.cpp'
[ -d /deps/git/github.com/ggerganov/llama.cpp ] && ln -sfn /deps/git/github.com/ggerganov/llama.cpp /deps/git/github.com/ggerganov/llama.cpp.git || true
mkdir -p $(dirname /deps/git/github.com/google/XNNPACK)
( git clone --mirror https://github.com/google/XNNPACK.git /deps/git/github.com/google/XNNPACK 2>/dev/null || git clone --mirror https://github.com/google/XNNPACK /deps/git/github.com/google/XNNPACK ) || echo 'WARN: could not mirror https://github.com/google/XNNPACK'
[ -d /deps/git/github.com/google/XNNPACK ] && ln -sfn /deps/git/github.com/google/XNNPACK /deps/git/github.com/google/XNNPACK.git || true
mkdir -p $(dirname /deps/git/github.com/inclavare-containers/librats)
( git clone --mirror https://github.com/inclavare-containers/librats.git /deps/git/github.com/inclavare-containers/librats 2>/dev/null || git clone --mirror https://github.com/inclavare-containers/librats /deps/git/github.com/inclavare-containers/librats ) || echo 'WARN: could not mirror https://github.com/inclavare-containers/librats'
[ -d /deps/git/github.com/inclavare-containers/librats ] && ln -sfn /deps/git/github.com/inclavare-containers/librats /deps/git/github.com/inclavare-containers/librats.git || true
mkdir -p $(dirname /deps/git/github.com/jedisct1/libsodium)
( git clone --mirror https://github.com/jedisct1/libsodium.git /deps/git/github.com/jedisct1/libsodium 2>/dev/null || git clone --mirror https://github.com/jedisct1/libsodium /deps/git/github.com/jedisct1/libsodium ) || echo 'WARN: could not mirror https://github.com/jedisct1/libsodium'
[ -d /deps/git/github.com/jedisct1/libsodium ] && ln -sfn /deps/git/github.com/jedisct1/libsodium /deps/git/github.com/jedisct1/libsodium.git || true
mkdir -p $(dirname /deps/git/github.com/leetal/ios-cmake)
( git clone --mirror https://github.com/leetal/ios-cmake.git /deps/git/github.com/leetal/ios-cmake 2>/dev/null || git clone --mirror https://github.com/leetal/ios-cmake /deps/git/github.com/leetal/ios-cmake ) || echo 'WARN: could not mirror https://github.com/leetal/ios-cmake'
[ -d /deps/git/github.com/leetal/ios-cmake ] && ln -sfn /deps/git/github.com/leetal/ios-cmake /deps/git/github.com/leetal/ios-cmake.git || true
mkdir -p $(dirname /deps/git/github.com/lh3/bwa)
( git clone --mirror https://github.com/lh3/bwa.git /deps/git/github.com/lh3/bwa 2>/dev/null || git clone --mirror https://github.com/lh3/bwa /deps/git/github.com/lh3/bwa ) || echo 'WARN: could not mirror https://github.com/lh3/bwa'
[ -d /deps/git/github.com/lh3/bwa ] && ln -sfn /deps/git/github.com/lh3/bwa /deps/git/github.com/lh3/bwa.git || true
mkdir -p $(dirname /deps/git/github.com/libuv/libuv)
( git clone --mirror https://github.com/libuv/libuv.git /deps/git/github.com/libuv/libuv 2>/dev/null || git clone --mirror https://github.com/libuv/libuv /deps/git/github.com/libuv/libuv ) || echo 'WARN: could not mirror https://github.com/libuv/libuv'
[ -d /deps/git/github.com/libuv/libuv ] && ln -sfn /deps/git/github.com/libuv/libuv /deps/git/github.com/libuv/libuv.git || true
mkdir -p $(dirname /deps/git/github.com/madler/zlib)
( git clone --mirror https://github.com/madler/zlib.git /deps/git/github.com/madler/zlib 2>/dev/null || git clone --mirror https://github.com/madler/zlib /deps/git/github.com/madler/zlib ) || echo 'WARN: could not mirror https://github.com/madler/zlib'
[ -d /deps/git/github.com/madler/zlib ] && ln -sfn /deps/git/github.com/madler/zlib /deps/git/github.com/madler/zlib.git || true
mkdir -p $(dirname /deps/git/github.com/mozilla/perf-automation)
( git clone --mirror https://github.com/mozilla/perf-automation.git /deps/git/github.com/mozilla/perf-automation 2>/dev/null || git clone --mirror https://github.com/mozilla/perf-automation /deps/git/github.com/mozilla/perf-automation ) || echo 'WARN: could not mirror https://github.com/mozilla/perf-automation'
[ -d /deps/git/github.com/mozilla/perf-automation ] && ln -sfn /deps/git/github.com/mozilla/perf-automation /deps/git/github.com/mozilla/perf-automation.git || true
mkdir -p $(dirname /deps/git/github.com/nodejs/uvwasi)
( git clone --mirror https://github.com/nodejs/uvwasi.git /deps/git/github.com/nodejs/uvwasi 2>/dev/null || git clone --mirror https://github.com/nodejs/uvwasi /deps/git/github.com/nodejs/uvwasi ) || echo 'WARN: could not mirror https://github.com/nodejs/uvwasi'
[ -d /deps/git/github.com/nodejs/uvwasi ] && ln -sfn /deps/git/github.com/nodejs/uvwasi /deps/git/github.com/nodejs/uvwasi.git || true
mkdir -p $(dirname /deps/git/github.com/simd-everywhere/simde)
( git clone --mirror https://github.com/simd-everywhere/simde.git /deps/git/github.com/simd-everywhere/simde 2>/dev/null || git clone --mirror https://github.com/simd-everywhere/simde /deps/git/github.com/simd-everywhere/simde ) || echo 'WARN: could not mirror https://github.com/simd-everywhere/simde'
[ -d /deps/git/github.com/simd-everywhere/simde ] && ln -sfn /deps/git/github.com/simd-everywhere/simde /deps/git/github.com/simd-everywhere/simde.git || true
mkdir -p $(dirname /deps/git/github.com/tensorflow/tensorflow)
( git clone --mirror https://github.com/tensorflow/tensorflow.git /deps/git/github.com/tensorflow/tensorflow 2>/dev/null || git clone --mirror https://github.com/tensorflow/tensorflow /deps/git/github.com/tensorflow/tensorflow ) || echo 'WARN: could not mirror https://github.com/tensorflow/tensorflow'
[ -d /deps/git/github.com/tensorflow/tensorflow ] && ln -sfn /deps/git/github.com/tensorflow/tensorflow /deps/git/github.com/tensorflow/tensorflow.git || true
mkdir -p $(dirname /deps/git/github.com/wasm-micro-runtime/sightglass)
( git clone --mirror https://github.com/wasm-micro-runtime/sightglass.git /deps/git/github.com/wasm-micro-runtime/sightglass 2>/dev/null || git clone --mirror https://github.com/wasm-micro-runtime/sightglass /deps/git/github.com/wasm-micro-runtime/sightglass ) || echo 'WARN: could not mirror https://github.com/wasm-micro-runtime/sightglass'
[ -d /deps/git/github.com/wasm-micro-runtime/sightglass ] && ln -sfn /deps/git/github.com/wasm-micro-runtime/sightglass /deps/git/github.com/wasm-micro-runtime/sightglass.git || true
mkdir -p $(dirname /deps/git/github.com/zeux/meshoptimizer)
( git clone --mirror https://github.com/zeux/meshoptimizer.git /deps/git/github.com/zeux/meshoptimizer 2>/dev/null || git clone --mirror https://github.com/zeux/meshoptimizer /deps/git/github.com/zeux/meshoptimizer ) || echo 'WARN: could not mirror https://github.com/zeux/meshoptimizer'
[ -d /deps/git/github.com/zeux/meshoptimizer ] && ln -sfn /deps/git/github.com/zeux/meshoptimizer /deps/git/github.com/zeux/meshoptimizer.git || true
mkdir -p $(dirname /deps/git/github.com/zyantific/zycore-c)
( git clone --mirror https://github.com/zyantific/zycore-c.git /deps/git/github.com/zyantific/zycore-c 2>/dev/null || git clone --mirror https://github.com/zyantific/zycore-c /deps/git/github.com/zyantific/zycore-c ) || echo 'WARN: could not mirror https://github.com/zyantific/zycore-c'
[ -d /deps/git/github.com/zyantific/zycore-c ] && ln -sfn /deps/git/github.com/zyantific/zycore-c /deps/git/github.com/zyantific/zycore-c.git || true
mkdir -p $(dirname /deps/git/github.com/zyantific/zydis)
( git clone --mirror https://github.com/zyantific/zydis.git /deps/git/github.com/zyantific/zydis 2>/dev/null || git clone --mirror https://github.com/zyantific/zydis /deps/git/github.com/zyantific/zydis ) || echo 'WARN: could not mirror https://github.com/zyantific/zydis'
[ -d /deps/git/github.com/zyantific/zydis ] && ln -sfn /deps/git/github.com/zyantific/zydis /deps/git/github.com/zyantific/zydis.git || true
git config --global --replace-all url."file:///deps/git/github.com/".insteadOf "https://github.com/"
# git >=2.38 blocks the file:// transport for SUBMODULES (CVE-2022-39253);
# our mirrors are local and trusted, so re-enable it.
git config --global protocol.file.allow always

# simde (pulled by FetchContent) has its own submodule: nemequ/munit.
mkdir -p /deps/git/github.com/nemequ
if [ ! -d /deps/git/github.com/nemequ/munit ]; then
  git clone --mirror https://github.com/nemequ/munit.git /deps/git/github.com/nemequ/munit \
    || echo "WARN: could not mirror munit"
fi
[ -d /deps/git/github.com/nemequ/munit ] && \
  ln -sfn /deps/git/github.com/nemequ/munit /deps/git/github.com/nemequ/munit.git || true

# --- wamr: skip simde submodules ---
# simde's only submodule (nemequ/munit) is for ITS OWN test suite and is not
# needed here; FetchContent's submodule update fails offline, so disable it.
SC="$SRC/wamr/core/iwasm/libraries/simde/simde.cmake"
if [ -f "$SC" ]; then
  grep -q 'GIT_SUBMODULES' "$SC" || \
    sed -i -E 's#^([[:space:]]*)(GIT_TAG[[:space:]].*)$#\1\2\n\1GIT_SUBMODULES ""#' "$SC"
fi
