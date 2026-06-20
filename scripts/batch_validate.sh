#!/bin/bash
# Batch validator for cybergym-e2e datasets
#
# Usage:
#   bash scripts/batch_validate.sh [tasks_file] [max_parallel]
#
# Options:
#   MAX_PARALLEL=N                 Parallel jobs (default: 20)
#
# Examples:
#   # Validate with default settings
#   bash scripts/batch_validate.sh scripts/tasks_30.txt 4
#
#   # With custom parallel count
#   bash scripts/batch_validate.sh scripts/tasks_30.txt 10
#
#   # Stop all running validation jobs
#   bash scripts/batch_validate.sh --stop

set -euo pipefail

# Handle --stop first
if [[ "${1:-}" == "--stop" ]]; then
    echo "Stopping all validation processes..."

    # Kill batch_validate.sh processes
    pkill -9 -f "batch_validate.sh" 2>/dev/null || true

    # Kill dataset_validate.py processes
    pkill -9 -f "dataset_validate.py" 2>/dev/null || true

    # Kill Docker containers. Disable for now to avoid killing unrelated containers.
    # docker ps -q 2>/dev/null | head -20 | xargs -r docker kill 2>/dev/null || true

    echo "Done."
    exit 0
fi

# Configuration
TASKS_FILE="${1:-scripts/tasks_30.txt}"
MAX_PARALLEL="${2:-${MAX_PARALLEL:-20}}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="dataset_validation_logs"

# Create log directory
mkdir -p "$LOG_DIR"

# Cleanup function
CLEANUP_DONE=0
cleanup() {
    if [ "$CLEANUP_DONE" = "1" ]; then
        return
    fi
    CLEANUP_DONE=1

    echo ""
    echo "[$(date +%H:%M:%S)] Received shutdown signal, cleaning up..."

    # Kill all child processes
    pkill -P $$ 2>/dev/null || true

    # Kill dataset_validate processes
    pkill -f "dataset_validate.py" 2>/dev/null || true

    # Kill Docker containers. Disable for now to avoid killing unrelated containers.
    # docker ps -q 2>/dev/null | head -20 | xargs -r docker kill 2>/dev/null || true

    echo "[$(date +%H:%M:%S)] Cleanup complete"
    exit 130
}

trap cleanup SIGTERM SIGINT SIGHUP

# Validate task file
if [ ! -f "$TASKS_FILE" ]; then
    echo "ERROR: Task file not found: $TASKS_FILE"
    exit 1
fi

TOTAL=$(wc -l < "$TASKS_FILE" | tr -d ' ')

echo "=========================================="
echo "Batch Validator"
echo "=========================================="
echo "Tasks file: $TASKS_FILE ($TOTAL tasks)"
echo "Max parallel: $MAX_PARALLEL"
echo "Log directory: $LOG_DIR"
echo "=========================================="
echo ""

# Function to validate a single task
validate_task() {
    local task="$1"
    local task_safe="${task//\//_}"
    local log_file="$LOG_DIR/${task_safe}.log"

    echo "[$(date +%H:%M:%S)] Starting: $task"

    # Run validation
    local output
    local exit_code=0
    output=$(python3 "$SCRIPT_DIR/dataset_validate.py" "$task" 2>&1 | tee "$log_file") || exit_code=$?

    # Check for success in output - check if all stages are 'passed'
    if grep -q "'stage1': 'passed'" "$log_file" && \
       grep -q "'stage2': 'passed'" "$log_file" && \
       grep -q "'stage3': 'passed'" "$log_file" && \
       grep -q "'stage4': 'passed'" "$log_file"; then
        echo "[$(date +%H:%M:%S)] SUCCESS: $task"
        # Show stage results
        grep -E "Results:" "$log_file" | sed 's/^/    /' || true
        return 0
    else
        echo "[$(date +%H:%M:%S)] FAILED:  $task"
        # Show stage results
        grep -E "Results:" "$log_file" | sed 's/^/    /' || true
        return 1
    fi
}

export -f validate_task
export SCRIPT_DIR LOG_DIR

# Run validations in parallel
echo "Starting parallel validation..."
echo ""

START_TIME=$(date +%s)

# Run with || true to ensure we continue to summary even if tasks fail
cat "$TASKS_FILE" | xargs -P "$MAX_PARALLEL" -I {} bash -c 'validate_task "$@"' _ {} || true

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "=========================================="
echo "Validation complete! (${DURATION}s / $((DURATION/60))m)"
echo "=========================================="

# Summarize results
python3 -c "
import os
import re

tasks_file = '$TASKS_FILE'
log_dir = '$LOG_DIR'

# Read task list
with open(tasks_file) as f:
    tasks = [line.strip() for line in f if line.strip() and not line.startswith('#')]

passed = 0
failed = 0
no_result = 0

print('')
print('=== RESULTS ===')

for task in tasks:
    task_safe = task.replace('/', '_')
    log_file = os.path.join(log_dir, f'{task_safe}.log')

    if not os.path.exists(log_file):
        no_result += 1
        print(f'  [??] {task} (no log)')
        continue

    with open(log_file) as f:
        content = f.read()

    # Check all stages passed - look for 'passed' string
    stages = {}
    # Try the format: 'stage1': 'passed'
    for match in re.finditer(r\"'(stage\d)': '(passed|failed|error)'\", content):
        stages[match.group(1)] = match.group(2) == 'passed'
    
    # Fallback to old format: 'stage1': {'passed': True}
    if not stages:
        for match in re.finditer(r\"'(stage\d)': {'passed': (True|False)\", content):
            stages[match.group(1)] = match.group(2) == 'True'

    if len(stages) == 4 and all(stages.values()):
        passed += 1
        print(f'  [OK] {task}')
    else:
        failed += 1
        stage_summary = ' '.join([f'{s[-1]}:{\"✓\" if stages.get(s, False) else \"✗\"}' for s in ['stage1', 'stage2', 'stage3', 'stage4']])
        print(f'  [XX] {task} [{stage_summary}]')

print('')
print('=== SUMMARY ===')
print(f'Total: {len(tasks)} | Passed: {passed} | Failed: {failed} | No Result: {no_result}')
print(f'Logs in: {log_dir}')
"
