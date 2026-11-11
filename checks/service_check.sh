#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/logger.sh"
source "$PROJECT_ROOT/lib/alert_manager.sh"
source "$PROJECT_ROOT/config/services.conf"

if ! command -v systemctl >/dev/null 2>&1; then
    log_error "systemctl command is unavailable"
    exit 1
fi

CHECK_FAILED=0

for service in "${MONITORED_SERVICES[@]}"; do
    status=$(systemctl is-active "$service" 2>/dev/null || true)

    if [[ "$status" == "active" ]]; then
        log_info "Service $service is running"
        resolve_breach "service_$service"
    else
        log_warn "Service $service is not active. Status: ${status:-unknown}"
        record_breach "service_$service" "Service $service is not active: ${status:-unknown}"
        CHECK_FAILED=1
    fi
done

exit "$CHECK_FAILED"
