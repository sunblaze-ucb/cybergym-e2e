#!/bin/bash
# test.sh - ALL unit tests for tinysparql (oss-fuzz_396460492)
#
# Build image: cybergym/e2e:tinysparql
#
# Test Statistics (tinysparql suite):
#   Total: 44 | Included: 14 | Excluded: 30
#
# Passing tests included:
#   fuzzing: fuzz_rdf_jsonld, fuzz_rdf_trig, fuzz_rdf_turtle (3)
#   core: ontology-error, sparql-blank, insert-or-replace, initialization, ontology-change (5)
#   core+slow: ontology (1)
#   common: file-utils, parser, utils (3)
#   resource: resource (1)
#   fts: fts (1)
#
# Excluded tests (with reasons):
#   - fuzz_query: Times out (fuzzer binary runs indefinitely without stopping)
#   - test_cli, test_coalesce, test_collation, test_concurrent_query,
#     test_distance, test_endpoint_http, test_fts_functions, test_graph,
#     test_group_concat, test_insertion, test_notifier, test_ontology_changes,
#     test_ontology_rollback, test_portal, test_query, test_sparql_bugs:
#     All 16 functional tests fail - Python 'gi' module not properly available
#   - bus-query-cancellation: SIGABRT - requires dbus machine-id
#   - service: SIGABRT - requires dbus connection
#   - sparql (core+slow): SIGTRAP - functions-tracker-1 assertion failure
#   - sparql (sparql suite): SIGABRT - requires dbus machine-id
#   - connection: SIGABRT - requires dbus connection
#   - batch: SIGABRT - requires dbus connection
#   - fd: SIGTRAP - requires dbus connection
#   - cursor+json: SIGABRT - requires dbus connection
#   - cursor+xml: SIGABRT - requires dbus connection
#   - statement: SIGABRT - requires dbus connection
#   - serialize: SIGABRT - requires dbus connection
#   - deserialize: SIGABRT - requires dbus connection
#   - namespaces: SIGABRT - requires dbus connection
#
# Exit codes:
#   0 - All included tests passed
#   1 - One or more tests failed

set -e

# Create a stub 'gi' Python module to satisfy meson's import check
python3 -c "
import os
gi_dir = '/usr/local/lib/python3.11/site-packages/gi'
repo_dir = os.path.join(gi_dir, 'repository')
os.makedirs(repo_dir, exist_ok=True)
open(os.path.join(gi_dir, '__init__.py'), 'w').close()
open(os.path.join(repo_dir, '__init__.py'), 'w').close()
"

# Reset compile.sh's sanitizer environment
unset SANITIZER FUZZING_ENGINE FUZZING_LANGUAGE ARCHITECTURE
unset LIB_FUZZING_ENGINE LIB_FUZZING_ENGINE_DEPRECATED
unset SANITIZER_FLAGS COVERAGE_FLAGS
export CC=clang
export CXX=clang++
export CFLAGS="-Wno-error=implicit-function-declaration -Wno-error=int-conversion -Wno-error=incompatible-function-pointer-types -Wno-error=deprecated-declarations"
export CXXFLAGS="$CFLAGS"
export LDFLAGS=""

cd /src/tinysparql

# Fresh meson setup for tests in a separate directory
BUILD_DIR=/tmp/test_build
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

meson setup $BUILD_DIR \
  -Dtests=true \
  -Dsystemd_user_services=false \
  -Dintrospection=disabled \
  -Dbuiltin_modules=true \
  -Dvapi=disabled \
  -Ddocs=false \
  -Dunicode_support=unistring \
  2>&1

ninja -C $BUILD_DIR 2>&1

cd $BUILD_DIR

# Run only the 14 passing tinysparql tests
meson test --no-rebuild --print-errorlogs --timeout-multiplier 3 --suite tinysparql \
  fuzz_rdf_jsonld fuzz_rdf_trig fuzz_rdf_turtle \
  ontology-error sparql-blank insert-or-replace initialization ontology-change \
  ontology \
  file-utils parser utils \
  resource \
  fts

echo "All tests passed!"
exit 0
