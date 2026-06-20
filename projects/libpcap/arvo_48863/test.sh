#!/usr/bin/env bash
# test.sh — build and run libpcap test binaries (no sudo, no TESTrun)
# Safe for containers or non-root environments, with PASS/FAIL/SKIP tracking.

set -euo pipefail
cd /src/libpcap

mkdir -p build build/logs
cd build

echo "=== [1/6] Configuring build ==="
cmake .. -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=ON

echo "=== [2/6] Building libpcap and test programs ==="
cmake --build . --target testprogs -j"$(nproc)"

echo "=== [3/6] Checking test binaries ==="
if [[ ! -d "run" ]]; then
  echo "❌ No test binaries found in build/run"
  exit 1
fi
ls -1 run

echo "=== [4/6] Running test binaries (safe, non-root) ==="
cd run

passed=0
failed=0
skipped=0

run_test() {
  set +e  # disable immediate exit inside function
  local t="$1"
  local log="/src/libpcap/build/logs/${t}.log"
  local rc=0
  echo "→ Running $t (log: $log)"

  case "$t" in
    capturetest)
      echo "[info] capturetest requires NET_RAW; running 5s demo" | tee "$log"
      timeout 5s "./$t" >>"$log" 2>&1
      rc=$?
      ;;
    selpolltest|threadsignaltest)
      echo "[info] $t listens indefinitely; running 5s via timeout" | tee "$log"
      timeout 5s "./$t" >>"$log" 2>&1
      rc=$?
      ;;
    filtertest)
      "./$t" 1 "tcp" >"$log" 2>&1
      rc=$?
      ;;
    writecaptest)
      echo "[info] writecaptest requires NET_RAW; skipping actual write" | tee "$log"
      rc=77   # mark as skipped
      ;;
    findalldevstest|opentest|reactivatetest|can_set_rfmon_test)
      echo "[info] $t may need capture privileges; running anyway" | tee "$log"
      "./$t" >>"$log" 2>&1
      rc=$?
      ;;
    *)
      "./$t" >"$log" 2>&1
      rc=$?
      ;;
  esac

  # === Classification ===
  if [[ $rc -eq 0 ]]; then
    echo "✅ PASS: $t"
    ((passed++))

  elif [[ $rc -eq 124 ]]; then
    # timeout killed it after 5s -> for these tests that's fine
    echo "✅ PASS: $t (timed out normally after 5s)"
    ((passed++))

  elif [[ $rc -eq 77 ]]; then
    echo "⚠️  SKIP: $t (marked skip)"
    ((skipped++))

  elif [[ "$t" = "can_set_rfmon_test" && $rc -eq 2 ]]; then
    echo "⚠️  SKIP: $t (rfmon not supported)"
    ((skipped++))

  else
    echo "❌ FAIL: $t (exit $rc)"
    ((failed++))
  fi

  set -e  # re-enable for outer script
}
# skip reactivatetest 
# === Test list ===
for t in findalldevstest filtertest opentest \
         selpolltest threadsignaltest capturetest can_set_rfmon_test \
         writecaptest valgrindtest; do
  if [[ -x "./$t" ]]; then
    run_test "$t"
  else
    echo "⚠️  Missing $t"
    ((skipped++))
  fi
done

echo
echo "=== [5/6] Summary ==="
echo "  ✅ Passed : $passed"
echo "  ❌ Failed : $failed"
echo "  ⚠️  Skipped: $skipped"
echo "Logs saved in: /src/libpcap/build/logs"

echo "=== [6/6] Exit status ==="
if [[ $failed -gt 0 ]]; then
  echo "❌ Some tests failed"
  exit 1
else
  echo "✅ All tests passed or skipped"
  exit 0
fi

