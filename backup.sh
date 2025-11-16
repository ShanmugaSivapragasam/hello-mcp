#!/bin/bash

# Backup script for MCP Server
# Usage: ./backup.sh [backup-type] [retention-days]

BACKUP_TYPE=${1:-"full"}
RETENTION_DAYS=${2:-7}
BACKUP_DIR="/opt/mcp-server/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[BACKUP]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Create backup directory
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        sudo mkdir -p "$BACKUP_DIR"
        sudo chown mcp-server:mcp-server "$BACKUP_DIR"
    fi
}

# Backup application files
backup_application() {
    print_status "Backing up application files..."

    local backup_file="${BACKUP_DIR}/mcp-server-app-${TIMESTAMP}.tar.gz"

    sudo tar -czf "$backup_file" \
        -C /opt/mcp-server \
        --exclude=logs \
        --exclude=tmp \
        .

    if [ $? -eq 0 ]; then
        print_status "Application backup created: $backup_file"
    else
        print_error "Application backup failed"
        return 1
    fi
}

# Backup configuration
backup_config() {
    print_status "Backing up configuration files..."

    local backup_file="${BACKUP_DIR}/mcp-server-config-${TIMESTAMP}.tar.gz"

    sudo tar -czf "$backup_file" \
        /opt/mcp-server/config \
        /etc/systemd/system/mcp-server.service \
        /etc/nginx/sites-available/mcp-server 2>/dev/null || true

    if [ $? -eq 0 ]; then
        print_status "Configuration backup created: $backup_file"
    else
        print_error "Configuration backup failed"
        return 1
    fi
}

# Backup logs
backup_logs() {
    print_status "Backing up log files..."

    local backup_file="${BACKUP_DIR}/mcp-server-logs-${TIMESTAMP}.tar.gz"

    sudo tar -czf "$backup_file" \
        -C /opt/mcp-server/logs \
        --exclude='*.tmp' \
        .

    if [ $? -eq 0 ]; then
        print_status "Logs backup created: $backup_file"
    else
        print_error "Logs backup failed"
        return 1
    fi
}

# Cleanup old backups
cleanup_old_backups() {
    print_status "Cleaning up backups older than $RETENTION_DAYS days..."

    find "$BACKUP_DIR" -name "mcp-server-*.tar.gz" -mtime +$RETENTION_DAYS -delete

    local remaining_count=$(find "$BACKUP_DIR" -name "mcp-server-*.tar.gz" | wc -l)
    print_status "Cleanup completed. $remaining_count backup files remaining."
}

# Create backup manifest
create_manifest() {
    local manifest_file="${BACKUP_DIR}/backup-manifest-${TIMESTAMP}.txt"

    cat > "$manifest_file" << EOF
MCP Server Backup Manifest
==========================
Backup Date: $(date)
Backup Type: $BACKUP_TYPE
Retention: $RETENTION_DAYS days
Server: $(hostname)
User: $(whoami)

Files in this backup:
$(ls -la ${BACKUP_DIR}/*${TIMESTAMP}*)

System Info:
- OS: $(uname -a)
- Java Version: $(java -version 2>&1 | head -1)
- Disk Usage: $(df -h /opt/mcp-server)
- Service Status: $(sudo systemctl is-active mcp-server 2>/dev/null || echo "Not running")

EOF

    print_status "Backup manifest created: $manifest_file"
}

# Main backup function
perform_backup() {
    print_status "Starting $BACKUP_TYPE backup..."

    create_backup_dir

    case $BACKUP_TYPE in
        "full")
            backup_application
            backup_config
            backup_logs
            ;;
        "app")
            backup_application
            ;;
        "config")
            backup_config
            ;;
        "logs")
            backup_logs
            ;;
        *)
            print_error "Unknown backup type: $BACKUP_TYPE"
            print_status "Available types: full, app, config, logs"
            exit 1
            ;;
    esac

    create_manifest
    cleanup_old_backups

    print_status "🎉 Backup completed successfully"
}

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    print_warning "This script should be run with sudo for full access to system files"
fi

# Execute backup
perform_backup
