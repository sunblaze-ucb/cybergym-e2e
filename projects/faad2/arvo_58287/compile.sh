#!/usr/bin/env bash
set -euo pipefail

# keep your env as-is
export ASAN_OPTIONS=alloc_dealloc_mismatch=0:allocator_may_return_null=1:allocator_release_to_os_interval_ms=500:check_malloc_usable_size=0:detect_container_overflow=1:detect_odr_violation=0:detect_leaks=0:detect_stack_use_after_return=1:fast_unwind_on_fatal=0:handle_abort=1:handle_segv=1:handle_sigill=1:max_uar_stack_size_log=16:print_scariness=1:quarantine_size_mb=10:strict_memcmp=1:strip_path_prefix=/workspace/:symbolize=1:use_sigaltstack=1:dedup_token_length=3
export MSAN_OPTIONS=print_stats=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3
export UBSAN_OPTIONS=print_stacktrace=1:print_summary=1:silence_unsigned_overflow=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3
export FUZZER_ARGS="-rss_limit_mb=2560 -timeout=25"
export AFL_FUZZER_ARGS="-m none"
export FUZZING_ENGINE=libfuzzer
export SANITIZER=address
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c

compile() {
  cd "${SRC:-/src}/faad2"

  if [[ -x ./bootstrap ]]; then ./bootstrap || true; fi
  autoreconf -fi || true

  ./configure \
    --disable-shared \
    --enable-static \
    CFLAGS="${CFLAGS:-}" \
    CXXFLAGS="${CXXFLAGS:-}" \
    LDFLAGS="${CFLAGS:-}"

  make -j"$(nproc)"
  mkdir -p /out

  # Prefer provided libFuzzer; otherwise include address too
  if [[ -n "${LIB_FUZZING_ENGINE:-}" && -f "${LIB_FUZZING_ENGINE}" ]]; then
    FZ_LINK="${LIB_FUZZING_ENGINE}"
  else
    FZ_LINK="-fsanitize=fuzzer,address"
  fi

  # Compile harness as C (unmangled symbol) WITH CFLAGS (includes -fsanitize=address)
  "${CC:-clang}" ${CFLAGS:-} -Iinclude \
    -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION \
    -c fuzz/fuzz_decode.c -o fuzz_decode.o

  # Link with C++ (required by libFuzzer) WITH CXXFLAGS and CFLAGS
  "${CXX:-clang++}" ${CXXFLAGS:-} ${CFLAGS:-} \
    -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION \
    fuzz_decode.o \
    libfaad/.libs/libfaad.a \
    -lm \
    ${FZ_LINK} \
    -o /out/fuzz_decode
}

compile

