#!/usr/bin/env bash

export ASAN_OPTIONS=alloc_dealloc_mismatch=0:allocator_may_return_null=1:allocator_release_to_os_interval_ms=500:check_malloc_usable_size=0:detect_container_overflow=1:detect_odr_violation=0:detect_leaks=0:detect_stack_use_after_return=1:fast_unwind_on_fatal=0:handle_abort=1:handle_segv=1:handle_sigill=1:max_uar_stack_size_log=16:print_scariness=1:quarantine_size_mb=10:strict_memcmp=1:strip_path_prefix=/workspace/:symbolize=1:use_sigaltstack=1:dedup_token_length=3
export MSAN_OPTIONS=print_stats=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3
export UBSAN_OPTIONS=print_stacktrace=1:print_summary=1:silence_unsigned_overflow=1:strip_path_prefix=/workspace/:symbolize=1:dedup_token_length=3
export FUZZER_ARGS="-rss_limit_mb=2560 -timeout=25"
export AFL_FUZZER_ARGS="-m none"
export FUZZING_ENGINE=libfuzzer
export SANITIZER=memory
export ARCHITECTURE=x86_64
export FUZZING_LANGUAGE=c++

# Use clang-14 because clang-22's MSan doesn't detect this particular
# use-of-uninitialized-value bug in Lizard decompressor
LLVM14_DIR="/opt/llvm14"
export CC="$LLVM14_DIR/bin/clang"
export CCC="$LLVM14_DIR/bin/clang++"
export CXX="$LLVM14_DIR/bin/clang++"

# Build libFuzzer with clang-14
cd $SRC/libfuzzer
$CXX -O2 -std=c++17 -stdlib=libc++ -c *.cpp
ar rc /usr/lib/libFuzzingEngine.a *.o

# Copy MSan libraries
cp -R /usr/msan/lib/* /usr/local/lib/x86_64-unknown-linux-gnu/
cp -R /usr/msan/include/* /usr/local/include

# Build the project with clang-14
cd $SRC/c-blosc2
MSAN_FLAGS="-fsanitize=memory -fsanitize-memory-track-origins"
COMMON="-O1 -fno-omit-frame-pointer -gline-tables-only -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION $MSAN_FLAGS -fsanitize=fuzzer-no-link"
export CFLAGS="$COMMON"
export CXXFLAGS="$COMMON -stdlib=libc++"

cmake . -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX \
  -DCMAKE_C_FLAGS="$CFLAGS" -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  -DBUILD_FUZZERS=ON \
  -DCMAKE_EXE_LINKER_FLAGS="-L$LLVM14_DIR/lib/x86_64-unknown-linux-gnu -Wl,-rpath,$LLVM14_DIR/lib/x86_64-unknown-linux-gnu"

make clean 2>/dev/null || true
make -j$(nproc)

# Copy fuzzers to output
find . -name '*_fuzzer' -exec cp -v '{}' $OUT ';'
find . -name '*_fuzzer.dict' -exec cp -v '{}' $OUT ';'
zip -j $OUT/decompress_fuzzer_seed_corpus.zip compat/*.cdata
find . -name '*_fuzzer_seed_corpus.zip' -exec cp -v '{}' $OUT ';'
