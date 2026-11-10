#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/logger.sh"

# Prevent overlapping monitoring runs
mkdir -p "$PROJECT_ROOT/state"
exec 9>"$PROJECT_ROOT/state/monitor.lock"

if ! flock -n 9; then
    log_warn "Monitoring already running. Skipping this execution."
    exit 0
fi

CHECKS=(
    cpu_check.sh
    memory_check.sh
    disk_check.sh
    process_check.sh
    service_check.sh
)

FAILED_CHECKS=0

log_info "========== Monitoring started =========="

for check in "${CHECKS[@]}"; do

    CHECK_PATH="$PROJECT_ROOT/checks/$check"

    if [[ ! -f "$CHECK_PATH" ]]; then
        log_error "Check module missing: $check"
        ((FAILED_CHECKS++))
        continue
    fi

    log_info "Executing $check"

    if bash "$CHECK_PATH"; then
        log_info "$check completed successfully"
    else
        exit_code=$?
        log_error "$check failed with exit code $exit_code"
        ((FAILED_CHECKS++))
    fi

done

if (( FAILED_CHECKS > 0 )); then
    log_warn "Monitoring completed with $FAILED_CHECKS failed checks"
else
    log_info "All monitoring checks completed successfully"
fi

log_info "========== Monitoring finished =========="

exit "$(( FAILED_CHECKS > 0 ))"
