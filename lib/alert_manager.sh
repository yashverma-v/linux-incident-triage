#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$PROJECT_ROOT/state"
ALERT_STATE="$STATE_DIR/alerts.state"
ALERT_LOCK="$STATE_DIR/alerts.lock"

mkdir -p "$STATE_DIR"
touch "$ALERT_STATE"

source "$PROJECT_ROOT/lib/triage.sh"

record_breach() {
    local key="$1"
    local description="$2"
    local count
    local trigger_triage=0
    local tmp

    exec 8>"$ALERT_LOCK"
    flock -x 8

    count=$(awk -F'|' -v k="$key" '$1==k {print $2}' "$ALERT_STATE")
    count=${count:-0}
    count=$((count + 1))

    tmp=$(mktemp "$STATE_DIR/alerts.XXXXXX")

    if awk -F'|' -v k="$key" '$1!=k' "$ALERT_STATE" > "$tmp"; then
        printf '%s|%s|%s\n' "$key" "$count" "$description" >> "$tmp"
        mv "$tmp" "$ALERT_STATE"
    else
        rm -f "$tmp"
        flock -u 8
        return 1
    fi

    if (( count == 3 )); then
        trigger_triage=1
    fi

    flock -u 8

    if (( trigger_triage )); then
        log_warn "ALERT: $description"
        run_triage "$key" "$description"
    fi
}

resolve_breach() {
    local key="$1"
    local found
    local tmp

    exec 8>"$ALERT_LOCK"
    flock -x 8

    found=$(awk -F'|' -v k="$key" '$1==k {print "yes"; exit}' "$ALERT_STATE")

    if [[ "$found" == "yes" ]]; then
        tmp=$(mktemp "$STATE_DIR/alerts.XXXXXX")

        if awk -F'|' -v k="$key" '$1!=k' "$ALERT_STATE" > "$tmp"; then
            mv "$tmp" "$ALERT_STATE"
        else
            rm -f "$tmp"
            flock -u 8
            return 1
        fi

        flock -u 8
        log_info "RECOVERY: $key returned to normal"
    else
        flock -u 8
    fi
}
