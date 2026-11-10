
#!/bin/bash

# Memory health monitoring module

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/logger.sh"
source "$PROJECT_ROOT/lib/alert_manager.sh"
source "$PROJECT_ROOT/config/thresholds.conf"

mem_total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
mem_available=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)

if [[ -z "$mem_total" || -z "$mem_available" || "$mem_total" -le 0 ]]; then
    log_error "Unable to read memory statistics"
    exit 1
fi

memory_usage=$(awk -v total="$mem_total" -v available="$mem_available" \
    'BEGIN { printf "%.2f", (total - available) * 100 / total }')

echo "Memory Usage: ${memory_usage}%"

if awk -v usage="$memory_usage" -v threshold="$MEMORY_THRESHOLD" \
    'BEGIN { exit !(usage >= threshold) }'
then
    log_info "Memory threshold exceeded: ${memory_usage}%"
    record_breach "memory" "High memory utilization: ${memory_usage}%"
else
    log_info "Memory utilization is normal: ${memory_usage}%"
    resolve_breach "memory"
fi
