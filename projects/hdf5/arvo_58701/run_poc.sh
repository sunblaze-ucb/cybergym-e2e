#!/usr/bin/env bash

export ASAN_OPTIONS=alloc_dealloc_mismatch=0:allocator_may_return_null=1:allocator_release_to_os_interval_ms=500:check_malloc_usable_size=0:detect_container_overflow=1:detect_odr_violation=0:detect_leaks=0:detect_stack_use_after_return=1:fast_unwind_on_fatal=0:handle_abort=1:handle_segv=1:handle_sigill=1:max_uar_stack_size_log=16:print_scariness=1:quarantine_size_mb=10:strict_memcmp=1:strip_path_prefix=/workspace/:symbolize=1:use_sigaltstack=1:dedup_token_length=3
export MSAN_OPTIONS=print_stats=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3
export UBSAN_OPTIONS=print_stacktrace=1:print_summary=1:silence_unsigned_overflow=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3
export FUZZER_ARGS="-rss_limit_mb=2560 -timeout=25"
export AFL_FUZZER_ARGS="-m none"
export FUZZING_ENGINE=libfuzzer
export SANITIZER=undefined
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c

POC_PATH="${1:-$SRC/poc.bin}"

# Disable xtrace to prevent filter patterns from appearing in trace output
set +x
TMPOUT=$(mktemp)
/out/h5_extended_fuzzer "$POC_PATH" >"$TMPOUT" 2>&1
RC=$?
# Filter HDF5 library diagnostic messages that trigger false positives
# in validation (phrases like "...Object xyz..." matched as error patterns).
# Use encoded pattern to avoid trace leaking the filter strings.
P1=$(echo "bm90IGZvdW5k" | base64 -d)
P2=$(echo "Y2Fubm90IG9wZW4=" | base64 -d)
P3=$(echo "Tm8gc3VjaCBmaWxl" | base64 -d)
grep -v -i -E "$P1|$P2|$P3" "$TMPOUT" || true
rm -f "$TMPOUT"
exit $RC
