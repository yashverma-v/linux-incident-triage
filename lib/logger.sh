
#!/bin/bash

# Project logging module

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LOGGER_LOG_FILE="$PROJECT_ROOT/logs/toolkit.log"

_log() {
    local level="$1"
    shift

    local message="$*"
    local timestamp

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    printf '[%s] [%s] %s\n' "$timestamp" "$level" "$message" | tee -a "$LOGGER_LOG_FILE"
}

log_info() {
    _log "INFO" "$@"
}

log_warn() {
    _log "WARN" "$@"
}

log_error() {
    _log "ERROR" "$@"
}
