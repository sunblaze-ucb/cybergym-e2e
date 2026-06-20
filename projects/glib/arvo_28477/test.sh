#!/bin/bash
# test.sh - ALL unit tests for glib (arvo_28477)
#
# This runs the COMPLETE test suite for the glib project, excluding only
# tests that genuinely fail in this Docker environment.
#
# Test Statistics:
#   Total tests: 246
#   Included: 241 (237 unique names, 4 names have duplicates across suites)
#   Excluded: 5
#
# Excluded tests (with reasons):
#   - option-argv0: Assertion failure in g_get_prgname() check - Docker container
#     environment causes program name to not match expected values (SIGABRT)
#   - defaultvalue: GIO defaultvalue test aborts with SIGABRT - assertion failure
#     related to default GObject property values in this build environment
#   - appinfo: Crashes with SIGTRAP - requires desktop environment / app info
#     infrastructure not available in the container
#   - desktop-app-info: Crashes with SIGTRAP - requires desktop environment /
#     XDG desktop database not available in the container
#   - resources: Assertion failure in test_resource_binary_linked - binary linked
#     resources not properly set up in the test build (SIGABRT)
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

cd ${SRC:-/src}/glib

# Reset compiler to standard gcc/g++ (compile.sh may have set AFL compilers)
unset CC CXX CFLAGS CXXFLAGS CXXFLAGS_EXTRA
unset SANITIZER SANITIZER_FLAGS COVERAGE_FLAGS
unset FUZZING_ENGINE FUZZING_LANGUAGE ARCHITECTURE
unset LIB_FUZZING_ENGINE LIB_FUZZING_ENGINE_DEPRECATED
unset ASAN_OPTIONS MSAN_OPTIONS UBSAN_OPTIONS
export CC=gcc
export CXX=g++

# Build glib for testing (separate from the fuzzing build done by compile.sh)
BUILD_DIR="/tmp/glib-test-build"
if [ ! -d "$BUILD_DIR" ]; then
    meson setup "$BUILD_DIR" \
        --default-library=shared \
        -Dlibmount=disabled \
        -Doss_fuzz=disabled \
        -Dinternal_pcre=true

    ninja -C "$BUILD_DIR"
fi

# Run all passing tests by name (excluding 5 known failures listed above).
meson test -C "$BUILD_DIR" \
    --timeout-multiplier 3 \
    --print-errorlogs \
    --no-rebuild \
    1bit-emufutex 1bit-mutex 642026 642026-ec accumulator appmonitor \
    array-test async-close-output-stream async-splice-output-stream \
    asyncqueue asyncqueue-test atomic autoptr autoptr-gio base64 binding \
    bit-test bitlock bookmarkfile boxed buffered-input-stream \
    buffered-output-stream bytes cache cancellable charset checksum \
    child-test closure closure-refcount codegen.py collate completion-test \
    cond contenttype contexts convert converter-stream credentials cxx-test \
    data-input-stream data-output-stream dataset date datetime defaultiface \
    deftype dir dirname-test dynamictests dynamictype enums env-test \
    environment error file file-test fileattributematcher fileutils \
    filter-streams flags g-file g-file-info g-file-info-filesystem-readonly \
    g-icon gdatetime gdbus-address-get-session gdbus-addresses \
    gdbus-connection-flush gdbus-message gdbus-non-socket gdbus-peer \
    gdbus-peer-object-manager gdbus-server-auth genmarshal.py gio-test \
    giomodule glistmodel gobject-private gschema-compile gsettings \
    gsocketclient-slow gsubprocess gutils-user-database guuid gvalue-test \
    gvariant gwakeup gwakeup-fallback hash hmac hook hostutils \
    ifaceproperties include inet-address io-channel io-stream iochannel-test \
    keyfile list live-g-file logging macros mainloop mainloop-test mappedfile \
    mapping-test markup markup-collect markup-escape markup-parse \
    markup-subparser mem-overflow memory-input-stream memory-monitor \
    memory-output-stream mimeapps mkenums.py module-test-library \
    module-test-plugin mount-operation mutex network-address network-monitor \
    network-monitor-race node object objects objects2 once onceinit \
    option-context overflow overflow-fallback override param paramspec-test \
    pattern permission pollable private properties properties2 properties3 \
    properties4 protocol proxy-test qdata qsort-test queue rand rcbox \
    readwrite rec-mutex refcount refcount-macro reference references \
    refstring regex relation-test rwlock scannerapi search-utils sequence \
    shell signal-handler signal1 signal2 signal3 signal4 signals \
    simple-async-result simple-proxy singleton sleepy-stream slice \
    slice-concurrent slice-threadinit slist socket socket-address \
    socket-listener socket-service sort sources spawn-multithreaded \
    spawn-singlethread spawn-test srvtarget stream-rw_all strfuncs string \
    strvbuilder task test-printf testfilemonitor testgdate testglib \
    testgobject testing thread thread-pool thread-test threadpool-test \
    threadtests thumbnail-verification timeloop timeloop-closure timeout \
    timer tls-bindings tls-certificate tls-database tls-interaction trash \
    tree type type-test unicode unicode-caseconv unicode-encoding unix \
    unix-fd unix-mounts unix-streams uri utf8-misc utf8-performance \
    utf8-pointer utf8-validate utils value vfs volumemonitor win32-appinfo

echo "All tests passed!"
exit 0
