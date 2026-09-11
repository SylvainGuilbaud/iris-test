#!/usr/bin/env bash
set -u -o pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="${CASE1_LOG_DIR:-$ROOT_DIR/test/logs}"
mkdir -p "$LOG_DIR"
LOG_FILE="${CASE1_LOG_FILE:-$LOG_DIR/case_1_$(date '+%Y%m%d_%H%M%S').log}"

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

run_scenario() {
    local label="$1"
    local count="$2"
    local output
    local exit_code

    log "START ${label}: one disconnect followed by ${count} follow-up messages"
    output="$(python3 "$ROOT_DIR/test/case_1.py" --count "$count" 2>&1)"
    exit_code=$?

    while IFS= read -r line; do
        log "$line"
    done <<< "$output"

    if [ "$exit_code" -eq 0 ]; then
        log "RESULT PASS ${label}"
        return 0
    fi

    log "RESULT FAIL ${label} (exit ${exit_code})"
    return 1
}

log "Case 1 scenario test started"
log "Log file: $LOG_FILE"

passed=0
failed=0

if run_scenario "short stability" 3; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

if run_scenario "medium stability" 5; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

if run_scenario "extended stability" 10; then
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

log "SUMMARY passed=${passed} failed=${failed}"
if [ "$failed" -eq 0 ]; then
    log "FINAL PASS Case 1 remained usable across all scenarios"
    exit 0
fi

log "FINAL FAIL Review the log and IRIS production trace"
exit 1
