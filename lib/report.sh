#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

generate_incident_report() {
    local incident_type="$1"
    local description="$2"
    local evidence_file="${3:-}"

    local incident_dir="$PROJECT_ROOT/incidents"
    local report_tmp
    local report_file

    mkdir -p "$incident_dir" || {
        log_error "Unable to create incidents directory"
        return 1
    }

    if [[ -n "$evidence_file" && ! -f "$evidence_file" ]]; then
        log_error "Evidence file does not exist: $evidence_file"
        return 1
    fi

    report_tmp=$(mktemp "$incident_dir/.report.XXXXXXXX.tmp") || {
        log_error "Unable to create temporary report"
        return 1
    }

    if ! {
        echo "LINUX INCIDENT REPORT"
        echo "====================="
        echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname: $(hostname)"
        echo "Incident: $incident_type"
        echo "Description: $description"
        echo "Evidence: ${evidence_file:-Not available}"
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
    } > "$report_tmp"; then
        rm -f "$report_tmp"
        log_error "Failed while writing incident report"
        return 1
    fi

    report_file="$incident_dir/incident_$(date '+%Y%m%d_%H%M%S')_$(basename "$report_tmp" | cut -d. -f3).txt"

    if ! mv "$report_tmp" "$report_file"; then
        rm -f "$report_tmp"
        log_error "Unable to finalize incident report"
        return 1
    fi

    GENERATED_REPORT="$report_file"
    log_info "Incident report generated: $report_file"
    return 0
}
