#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/logger.sh"
source "$PROJECT_ROOT/config/services.conf"

for service in "${MONITORED_SERVICES[@]}"; do

    if ! command -v systemctl >/dev/null 2>&1; then
        log_error "systemctl command is unavailable"
        exit 1
    fi

    status=$(systemctl is-active "$service" 2>/dev/null || true)

    if [[ "$status" == "active" ]]; then
        log_info "Service $service is running"
    else
        log_warn "Service $service is not active. Status: ${status:-unknown}"
    fi

done
