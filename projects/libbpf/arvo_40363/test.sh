#!/bin/bash
# test.sh - ALL unit tests for libbpf (arvo_40769)
#
# Test Summary:
# libbpf does not have traditional unit tests that can run without a VM.
# The project's test suite consists of:
#   1. Build verification tests (test_compile.sh) - requires building libbpf from source
#   2. Kernel BPF selftests - require a VM with specific kernel versions and root access
#   3. Fuzzer tests - can run with pre-built fuzzer and seed corpus
#
# This container has a pre-built fuzzer (/out/bpf-object-fuzzer) and seed corpus
# (/src/minimal.bpf.o), so we use that for testing. The fuzzer tests the core
# BPF object parsing functionality of libbpf (bpf_object__open, etc).
#
# Test Statistics:
#   Available tests: 1 (fuzzer seed corpus test)
#   Included: 1
#   Excluded: 0
#
# Excluded tests (with reasons):
#   - Kernel selftests (test_progs, test_verifier, test_maps): Require a VM with root
#     access and specific kernel versions (4.9.0, 5.5.0, or LATEST). Cannot run in
#     this Docker container environment.
#   - Build verification (test_compile.sh): Requires libelf-dev headers which are
#     not installed in this container. The container has pre-built binaries instead.
#
# Exit codes:
#   0 - All tests passed
#   1 - One or more tests failed

set -e

# Set sanitizer options for consistent behavior
export ASAN_OPTIONS=alloc_dealloc_mismatch=0:allocator_may_return_null=1:allocator_release_to_os_interval_ms=500:check_malloc_usable_size=0:detect_container_overflow=1:detect_odr_violation=0:detect_leaks=0:detect_stack_use_after_return=1:fast_unwind_on_fatal=0:handle_abort=1:handle_segv=1:handle_sigill=1:max_uar_stack_size_log=16:print_scariness=1:quarantine_size_mb=10:strict_memcmp=1:strip_path_prefix=/workspace/:symbolize=1:use_sigaltstack=1:dedup_token_length=3
export UBSAN_OPTIONS=print_stacktrace=1:print_summary=1:silence_unsigned_overflow=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3

echo "=== libbpf Test Suite ==="
echo ""

# Test 1: Fuzzer seed corpus test
# This tests the core BPF object parsing functionality using the pre-built fuzzer
# and the seed corpus (minimal.bpf.o). The fuzzer exercises bpf_object__open()
# and related functions.
echo "Test 1: Fuzzer seed corpus test (bpf_object__open)"
echo "  Testing BPF object parsing with minimal.bpf.o..."
/out/bpf-object-fuzzer /src/minimal.bpf.o
echo "  PASSED"
echo ""

echo "=== All tests passed! ==="
exit 0
