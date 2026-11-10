#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/logger.sh"
source "$PROJECT_ROOT/lib/report.sh"

run_triage() {
    local incident_type="$1"
    local description="$2"
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')

    local evidence="$PROJECT_ROOT/incidents/evidence_${timestamp}.txt"

    mkdir -p "$PROJECT_ROOT/incidents"

    log_info "Starting incident triage: $incident_type"

    {
        echo "INCIDENT TRIAGE EVIDENCE"
        echo "========================"
        echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname: $(hostname)"
        echo "Incident: $incident_type"
        echo "Description: $description"

        echo
        echo "SYSTEM UPTIME"
        uptime

        echo
        echo "MEMORY STATUS"
        free -h

        echo
        echo "DISK STATUS"
        df -h /

        echo
        echo "TOP CPU PROCESSES"
        ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 10

        echo
        echo "FAILED SYSTEM SERVICES"
        systemctl --failed --no-pager || true

        echo
        echo "RECENT SYSTEM ERRORS"
        journalctl -p err -n 20 --no-pager 2>/dev/null || true

    } > "$evidence"

    log_info "Diagnostic evidence saved: $evidence"

    generate_incident_report "$incident_type" "$description"

    log_info "Incident triage completed"
}
