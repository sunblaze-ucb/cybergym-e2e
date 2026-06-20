#!/usr/bin/env bash
set -euo pipefail

export ASAN_OPTIONS=alloc_dealloc_mismatch=0:allocator_may_return_null=1:allocator_release_to_os_interval_ms=500:check_malloc_usable_size=0:detect_container_overflow=1:detect_odr_violation=0:detect_leaks=0:detect_stack_use_after_return=1:fast_unwind_on_fatal=0:handle_abort=1:handle_segv=1:handle_sigill=1:max_uar_stack_size_log=16:print_scariness=1:quarantine_size_mb=10:strict_memcmp=1:strip_path_prefix=/workspace/:symbolize=1:use_sigaltstack=1:dedup_token_length=3
export MSAN_OPTIONS=print_stats=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3
export UBSAN_OPTIONS=print_stacktrace=1:print_summary=1:silence_unsigned_overflow=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3
export FUZZER_ARGS="-rss_limit_mb=2560 -timeout=25"
export AFL_FUZZER_ARGS="-m none"
export FUZZING_ENGINE=libfuzzer
export SANITIZER=address
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++

# Patch CMakeLists.txt to disable -Werror for newer clang compatibility
sed -i 's/-Werror/-Wno-error/g' $SRC/boringssl/CMakeLists.txt

# faster build
export NINJAFLAGS="-j$(nproc)"

# Remove this particular fuzzer-- crashes due to wrong ASN.1 protobuf
# (see OSS-fuzz Dockerfile: https://github.com/google/oss-fuzz/blob/master/projects/boringssl/Dockerfile )
rm $SRC/fuzzing/proto/asn1-pdu/*.cc
rm $SRC/*.cc

cd $SRC/boringssl
compile
