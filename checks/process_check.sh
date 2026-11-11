#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/logger.sh"
source "$PROJECT_ROOT/lib/alert_manager.sh"
source "$PROJECT_ROOT/config/thresholds.conf"

echo "Top 5 CPU-consuming processes:"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6

if high_cpu=$(ps -eo pid=,comm=,%cpu= |
    awk -v threshold="$PROCESS_CPU_THRESHOLD" '
    $3+0 >= threshold {
        printf "%s (PID: %s, CPU: %s%%) ", $2, $1, $3
        found=1
    }
    END { exit !found }'); then

    log_warn "High CPU-consuming process detected: $high_cpu"
    record_breach "process_cpu" "High CPU process: $high_cpu"
else
    log_info "No process crossed the CPU threshold"
    resolve_breach "process_cpu"
fi
