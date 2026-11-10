#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$PROJECT_ROOT/lib/logger.sh"
source "$PROJECT_ROOT/lib/alert_manager.sh"
source "$PROJECT_ROOT/config/thresholds.conf"

FILESYSTEM="/"

disk_usage=$(df -P "$FILESYSTEM" | awk 'NR==2 {gsub("%","",$5); print $5}')
inode_usage=$(df -Pi "$FILESYSTEM" | awk 'NR==2 {gsub("%","",$5); print $5}')

if [[ ! "$disk_usage" =~ ^[0-9]+$ || ! "$inode_usage" =~ ^[0-9]+$ ]]; then
    log_error "Unable to read disk or inode statistics"
    exit 1
fi

echo "Disk Usage: ${disk_usage}%"
echo "Inode Usage: ${inode_usage}%"

# Disk utilization monitoring
if (( disk_usage >= DISK_THRESHOLD )); then
    log_info "Disk threshold exceeded: ${disk_usage}%"
    record_breach "disk" "High disk utilization: ${disk_usage}%"
else
    log_info "Disk utilization is normal: ${disk_usage}%"
    resolve_breach "disk"
fi

# Inode utilization monitoring
if (( inode_usage >= INODE_THRESHOLD )); then
    log_info "Inode threshold exceeded: ${inode_usage}%"
    record_breach "inode" "High inode utilization: ${inode_usage}%"
else
    log_info "Inode utilization is normal: ${inode_usage}%"
    resolve_breach "inode"
fi
