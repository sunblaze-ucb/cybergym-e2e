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

export CFLAGS="$CFLAGS \
  -Wno-error=unsafe-buffer-usage \
  -Wno-error=unsafe-buffer-usage-in-libc-call \
  -Wno-unsafe-buffer-usage \
  -Wno-unsafe-buffer-usage-in-libc-call \
  -Wno-error=shadow-field \
  -Wno-shadow-field \
  -Wno-error=unqualified-std-cast-call \
  -Wno-unqualified-std-cast-call"

export CXXFLAGS="$CXXFLAGS \
  -Wno-error=unsafe-buffer-usage \
  -Wno-error=unsafe-buffer-usage-in-libc-call \
  -Wno-unsafe-buffer-usage \
  -Wno-unsafe-buffer-usage-in-libc-call \
  -Wno-error=shadow-field \
  -Wno-shadow-field \
  -Wno-error=unqualified-std-cast-call \
  -Wno-unqualified-std-cast-call"

export CFLAGS="$CFLAGS -ferror-limit=0 -Wno-error \
  -Wno-unsafe-buffer-usage -Wno-unsafe-buffer-usage-in-libc-call \
  -Wno-shadow-field -Wno-unqualified-std-cast-call -Wno-format-signedness"

export CXXFLAGS="$CXXFLAGS -ferror-limit=0 -Wno-error \
  -Wno-unsafe-buffer-usage -Wno-unsafe-buffer-usage-in-libc-call \
  -Wno-shadow-field -Wno-unqualified-std-cast-call -Wno-format-signedness"


export CFLAGS="${CFLAGS/-Werror/} -Wno-error"
export CXXFLAGS="${CXXFLAGS/-Werror/} -Wno-error"

# CMakeLists.txt sets -Werror via set_directory_properties(PROPERTIES COMPILE_OPTIONS "-Werror")
# which overrides the general -Wno-error above (it comes later on the compile command line).
# Specific -Wno-error=<warning> flags survive regardless of -Werror ordering.
export CFLAGS="$CFLAGS \
  -Wno-error=reserved-identifier \
  -Wno-error=ignored-attributes \
  -Wno-error=extra-semi-stmt \
  -Wno-error=nan-infinity-disabled"

export CXXFLAGS="$CXXFLAGS \
  -Wno-error=reserved-identifier \
  -Wno-error=ignored-attributes \
  -Wno-error=extra-semi-stmt \
  -Wno-error=nan-infinity-disabled"

cd $SRC/librawspeed
compile
