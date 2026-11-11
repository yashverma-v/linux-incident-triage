#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/logger.sh"
source "$PROJECT_ROOT/lib/report.sh"

run_triage() {
    local incident_type="$1"
    local description="$2"

    local incident_dir="$PROJECT_ROOT/incidents"
    local evidence_tmp
    local evidence_file

    mkdir -p "$incident_dir" || {
        log_error "Unable to create incidents directory"
        return 1
    }

    evidence_tmp=$(mktemp "$incident_dir/.evidence.XXXXXXXX.tmp") || {
        log_error "Unable to create temporary evidence file"
        return 1
    }

    log_info "Starting incident triage: $incident_type"

    if ! {
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
        if command -v systemctl >/dev/null 2>&1; then
            systemctl --failed --no-pager || true
        else
            echo "systemctl unavailable"
        fi
        echo
        echo "RECENT SYSTEM ERRORS"
        if command -v journalctl >/dev/null 2>&1; then
            journalctl -p err -n 20 --no-pager 2>/dev/null || true
        else
            echo "journalctl unavailable"
        fi
    } > "$evidence_tmp"; then
        rm -f "$evidence_tmp"
        log_error "Failed while collecting incident evidence"
        return 1
    fi

    evidence_file="$incident_dir/evidence_$(date '+%Y%m%d_%H%M%S')_$(basename "$evidence_tmp" | cut -d. -f3).txt"

    if ! mv "$evidence_tmp" "$evidence_file"; then
        rm -f "$evidence_tmp"
        log_error "Unable to finalize incident evidence"
        return 1
    fi

    log_info "Diagnostic evidence saved: $evidence_file"

    if ! generate_incident_report "$incident_type" "$description" "$evidence_file"; then
        log_error "Incident report generation failed"
        return 1
    fi

    log_info "Incident triage completed"
    return 0
}
