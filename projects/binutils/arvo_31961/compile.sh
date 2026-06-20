#!/usr/bin/env bash

export ASAN_OPTIONS=alloc_dealloc_mismatch=0:allocator_may_return_null=1:allocator_release_to_os_interval_ms=500:check_malloc_usable_size=0:detect_container_overflow=1:detect_odr_violation=0:detect_leaks=0:detect_stack_use_after_return=1:fast_unwind_on_fatal=0:handle_abort=1:handle_segv=1:handle_sigill=1:max_uar_stack_size_log=16:print_scariness=1:quarantine_size_mb=10:strict_memcmp=1:strip_path_prefix=/workspace/:symbolize=1:use_sigaltstack=1:dedup_token_length=3
export MSAN_OPTIONS=print_stats=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3
export UBSAN_OPTIONS=print_stacktrace=1:print_summary=1:silence_unsigned_overflow=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3
export FUZZER_ARGS="-rss_limit_mb=2560 -timeout=25"
export AFL_FUZZER_ARGS="-m none"
export FUZZING_ENGINE=afl
export SANITIZER=address
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++

# Suppress warnings that clang 22 treats as errors but older clang did not
export CFLAGS="$CFLAGS -Wno-error=tautological-compare -Wno-error=unused-but-set-variable -Wno-error -fuse-ld=lld"
export CXXFLAGS_EXTRA="${CXXFLAGS_EXTRA:-} -fuse-ld=lld"
export AR=llvm-ar
export RANLIB=llvm-ranlib
export NM=llvm-nm
export LDFLAGS="${LDFLAGS:-} -fuse-ld=lld"

cd $SRC
compile
