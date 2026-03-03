#!/usr/bin/env bash
# restore.sh — Restore OpenClaw from disaster recovery backup
#
# Usage:
#   ./restore.sh /path/to/backup.tar.gz [--verify-only]
#   ./restore.sh --list-backups
#   ./restore.sh --latest
#
# The script will:
# 1. Validate the backup file
# 2. Show what will be restored
# 3. Confirm before proceeding
# 4. Extract to /root/openclaw-stock-home/.openclaw

set -euo pipefail

BACKUP_DIR="/root/openclaw-stock-home/.openclaw/backups"
RESTORE_DIR="/root/openclaw-stock-home/.openclaw"

# Parse arguments
BACKUP_FILE=""
VERIFY_ONLY=false
LIST_BACKUPS=false
LATEST=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --verify-only)
      VERIFY_ONLY=true
      shift
      ;;
    --list-backups)
      LIST_BACKUPS=true
      shift
      ;;
    --latest)
      LATEST=true
      shift
      ;;
    *)
      BACKUP_FILE="$1"
      shift
      ;;
  esac
done

# List backups
if [[ "${LIST_BACKUPS}" == "true" ]]; then
  echo "Available backups:"
  echo "=================="
  ls -lh "${BACKUP_DIR}"/*.tar.gz 2>/dev/null || echo "No backups found"
  echo ""
  echo "Latest symlink: $(readlink -f "${BACKUP_DIR}/latest.tar.gz" 2>/dev/null || echo "none")"
  exit 0
fi

# Use latest backup if requested
if [[ "${LATEST}" == "true" ]]; then
  if [[ -f "${BACKUP_DIR}/latest.tar.gz" ]]; then
    BACKUP_FILE="${BACKUP_DIR}/latest.tar.gz"
  else
    echo "ERROR: No latest backup found"
    exit 1
  fi
fi

# Validate backup file
if [[ -z "${BACKUP_FILE}" ]]; then
  echo "Usage: $0 <backup-file.tar.gz> [--verify-only]"
  echo ""
  echo "Options:"
  echo "  --verify-only    Check backup integrity without restoring"
  echo "  --list-backups   Show available backups"
  echo "  --latest         Use the most recent backup"
  echo ""
  echo "Example:"
  echo "  $0 /root/openclaw-stock-home/.openclaw/backups/openclaw-disaster-recovery-20260303_180000.tar.gz"
  exit 1
fi

if [[ ! -f "${BACKUP_FILE}" ]]; then
  echo "ERROR: Backup file not found: ${BACKUP_FILE}"
  exit 1
fi

# Check if manifest exists
MANIFEST_FILE="${BACKUP_FILE%.tar.gz}.manifest.json"
if [[ ! -f "${MANIFEST_FILE}" ]]; then
  echo "WARNING: No manifest file found at ${MANIFEST_FILE}"
  echo "Proceeding with restore without manifest..."
  USE_MANIFEST=false
else
  USE_MANIFEST=true
fi

echo "=== OpenClaw Disaster Recovery Restore ==="
echo ""
echo "Backup file: ${BACKUP_FILE}"

if [[ "${USE_MANIFEST}" == "true" ]]; then
  echo "Manifest: ${MANIFEST_FILE}"
  echo ""
  echo "Backup metadata:"
  echo "  Timestamp: $(jq -r '.timestamp' "${MANIFEST_FILE}" 2>/dev/null || echo "unknown")"
  echo "  Rules version: $(jq -r '.rulesVersion // "unknown"' "${MANIFEST_FILE}" 2>/dev/null || echo "unknown")"
  echo "  Excluded patterns: $(jq -r '.excludedCount // "unknown"' "${MANIFEST_FILE}" 2>/dev/null || echo "unknown")"
  echo "  Included patterns: $(jq -r '.includedCount // "unknown"' "${MANIFEST_FILE}" 2>/dev/null || echo "unknown")"
  echo ""
fi

# Verify backup integrity
echo "Verifying backup integrity..."
# Try different tar options for verification
if ! tar --extract --to-stdout --file="${BACKUP_FILE}" > /dev/null 2>&1; then
  echo "ERROR: Backup file is corrupted or invalid"
  exit 1
fi

# List contents
echo ""
echo "Backup contents:"
tar --list --file="${BACKUP_FILE}" | head -20
echo "  ... ($(tar --list --file="${BACKUP_FILE}" | wc -l | xargs) total items)"

# Restore or just verify
if [[ "${VERIFY_ONLY}" == "true" ]]; then
  echo ""
  echo "=== VERIFICATION COMPLETE ==="
  echo "Backup is valid and ready for restore."
  exit 0
fi

# Confirm restore
echo ""
echo "WARNING: This will overwrite files in ${RESTORE_DIR}"
read -p "Are you sure you want to restore? (yes/NO): " CONFIRM

if [[ "${CONFIRM}" != "yes" ]]; then
  echo "Restore cancelled."
  exit 0
fi

# Create backup of current state
echo ""
echo "Creating backup of current state..."
CURRENT_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CURRENT_BACKUP="${BACKUP_DIR}/pre-restore-${CURRENT_TIMESTAMP}.tar.gz"

tar --create --gzip \
  --file="${CURRENT_BACKUP}" \
  --directory="${RESTORE_DIR}" \
  --exclude='backups' \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='tmp' \
  . 2>/dev/null || true

echo "Current state backed up to: ${CURRENT_BACKUP}"

# Restore from backup
echo ""
echo "Restoring from backup..."
tar --extract --gzip \
  --file="${BACKUP_FILE}" \
  --directory="${RESTORE_DIR}" \
  --overwrite 2>&1 | tee /tmp/restore-log.txt

echo ""
echo "=== RESTORE COMPLETE ==="
echo ""
echo "What was restored:"
tar --list --file="${BACKUP_FILE}" 2>/dev/null | head -30
echo "  ... see /tmp/restore-log.txt for full list"

# Verify key files exist
echo ""
echo "Verifying key files..."
for file in "workspace/SOUL.md" "workspace/MEMORY.md" "openclaw.json" "skills/router-governor/SKILL.md"; do
  if [[ -f "${RESTORE_DIR}/${file}" ]]; then
    echo "  ✓ ${file}"
  else
    echo "  ✗ ${file} (missing)"
  fi
done

echo ""
echo "Next steps:"
echo "1. Restart OpenClaw: openclaw gateway restart"
echo "2. Verify status: openclaw status"
echo "3. Test Telegram bot functionality"
echo "4. Check any MCP servers are running"
