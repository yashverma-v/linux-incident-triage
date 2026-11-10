#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

generate_incident_report() {

    local incident_type="$1"
    local description="$2"

    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')

    local report="$PROJECT_ROOT/incidents/incident_${timestamp}.txt"

    {
        echo "LINUX INCIDENT REPORT"
        echo "====================="
        echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname: $(hostname)"
        echo "Incident: $incident_type"
        echo "Description: $description"
        echo
        echo "SYSTEM INFORMATION"
        echo "------------------"
        uptime
        free -h
        df -h /
        echo
        echo "TOP PROCESSES"
        echo "-------------"
        ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 10
        echo
        echo "RECENT TOOLKIT LOGS"
        echo "-------------------"
        tail -n 20 "$PROJECT_ROOT/logs/toolkit.log" 2>/dev/null || true
    } > "$report"

    log_info "Incident report generated: $report"

    echo "$report"
}
