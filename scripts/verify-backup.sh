#!/usr/bin/env bash
# verify-backup.sh - Verify backup integrity without extracting

set -euo pipefail

BACKUP_FILE="${1:-}"

if [[ -z "${BACKUP_FILE}" ]]; then
  echo "Usage: $0 <backup-file.tar.gz>"
  echo ""
  echo "Verifies backup integrity by checking:"
  echo "  1. File is valid tar.gz"
  echo "  2. Manifest exists and is valid JSON"
  echo "  3. Key files are included"
  exit 1
fi

if [[ ! -f "${BACKUP_FILE}" ]]; then
  echo "ERROR: Backup file not found: ${BACKUP_FILE}"
  exit 1
fi

echo "=== Verifying Backup: ${BACKUP_FILE} ==="
echo ""

# Step 1: Verify tar.gz integrity
echo "1. Checking tar.gz integrity..."
if tar --extract --to-stdout --file="${BACKUP_FILE}" > /dev/null 2>&1; then
  echo "   ✓ Archive is valid"
else
  echo "   ✗ Archive is corrupted"
  exit 1
fi

# Step 2: Check manifest
MANIFEST_FILE="${BACKUP_FILE%.tar.gz}.manifest.json"
echo "2. Checking manifest..."
if [[ -f "${MANIFEST_FILE}" ]]; then
  echo "   ✓ Manifest exists: ${MANIFEST_FILE}"
  if jq empty "${MANIFEST_FILE}" 2>/dev/null; then
    echo "   ✓ Manifest is valid JSON"
    echo "   Timestamp: $(jq -r '.timestamp' "${MANIFEST_FILE}")"
    echo "   Excluded: $(jq -r '.excludedCount' "${MANIFEST_FILE}") patterns"
    echo "   Included: $(jq -r '.includedCount' "${MANIFEST_FILE}") patterns"
  else
    echo "   ✗ Manifest is not valid JSON"
    exit 1
  fi
else
  echo "   ⚠ No manifest found (backup created without manifest)"
fi

# Step 3: Check key files
echo "3. Checking key files..."
KEY_FILES=(
  "workspace/SOUL.md"
  "workspace/MEMORY.md"
  "workspace/openclaw.json"
  "skills/router-governor/SKILL.md"
)

for file in "${KEY_FILES[@]}"; do
  if tar --list --file="${BACKUP_FILE}" 2>/dev/null | grep -q "^${file}$"; then
    echo "   ✓ ${file}"
  else
    echo "   ✗ ${file} (missing)"
  fi
done

echo ""
echo "=== Verification Complete ==="
