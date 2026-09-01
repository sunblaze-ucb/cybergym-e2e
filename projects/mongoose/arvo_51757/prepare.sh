#!/usr/bin/env bash

# Prepare.sh for ARVO projects
# Nothing to do!

# --- disable the one unit test that needs live internet ---
# test_sntp_server() queries udp://time.windows.com:123 and asserts it got a
# timestamp back. SNTP is UDP/123, so no HTTP proxy can carry it. Upstream
# already comments out the other two test_sntp_server() calls (time.apple.com
# and the default server); this disables the last one the same way. The rest of
# test_sntp() -- parsing, corrupt-packet handling -- still runs.
UT="$SRC/mongoose/test/unit_test.c"
if [ -f "$UT" ]; then
  sed -i 's|^\([[:space:]]*\)test_sntp_server("udp://time.windows.com:123");|\1// test_sntp_server("udp://time.windows.com:123");  // needs live SNTP|' "$UT"
  grep -q '// test_sntp_server("udp://time.windows.com' "$UT" \
    && echo "mongoose: disabled live SNTP test" \
    || echo "WARN: could not disable mongoose SNTP test"
fi
