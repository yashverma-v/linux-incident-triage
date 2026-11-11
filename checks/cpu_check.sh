#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/lib/logger.sh"
source "$PROJECT_ROOT/lib/alert_manager.sh"
source "$PROJECT_ROOT/config/thresholds.conf"

get_cpu_stats() {
    awk '/^cpu / {
        total = 0
        for (i = 2; i <= 9; i++) total += $i
        idle = $5 + $6
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

cpu_usage=$(awk -v t="$total_diff" -v i="$idle_diff" \
    'BEGIN { printf "%.2f", (t-i)*100/t }')

echo "CPU Usage: ${cpu_usage}%"

if awk -v u="$cpu_usage" -v t="$CPU_THRESHOLD" \
    'BEGIN { exit !(u >= t) }'
then
    record_breach "cpu" "High CPU utilization: ${cpu_usage}%"
else
    log_info "CPU utilization is normal: ${cpu_usage}%"
    resolve_breach "cpu"
fi
