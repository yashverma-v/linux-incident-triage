#!/bin/bash

# CPU health monitoring module

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/logger.sh"
source "$PROJECT_ROOT/lib/alert_manager.sh"
source "$PROJECT_ROOT/config/thresholds.conf"

get_cpu_stats() {
    awk '/^cpu / {
        idle = $5
        total = 0

        for (i = 2; i <= NF; i++) {
            total += $i
        }

        print total, idle
    }' /proc/stat
}

read -r total1 idle1 < <(get_cpu_stats)

sleep 1

read -r total2 idle2 < <(get_cpu_stats)

total_diff=$((total2 - total1))
idle_diff=$((idle2 - idle1))

if (( total_diff <= 0 )); then
    log_error "Unable to calculate CPU utilization"
    exit 1
fi

cpu_usage=$(awk -v total="$total_diff" -v idle="$idle_diff" \
    'BEGIN { printf "%.2f", (total - idle) * 100 / total }')

echo "CPU Usage: ${cpu_usage}%"

if awk -v usage="$cpu_usage" -v threshold="$CPU_THRESHOLD" \
    'BEGIN { exit !(usage >= threshold) }'
then
    log_info "CPU threshold exceeded: ${cpu_usage}%"
    record_breach "cpu" "High CPU utilization: ${cpu_usage}%"
else
    log_info "CPU utilization is normal: ${cpu_usage}%"
    resolve_breach "cpu"
fi

