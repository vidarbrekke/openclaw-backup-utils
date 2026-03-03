#!/usr/bin/env bash
# smoke.test.sh - Smoke tests for backup/restore scripts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/.."
WORKSPACE_DIR="${SCRIPTS_DIR}/.."

echo "=== OpenClaw Backup Utils Smoke Tests ==="
echo ""

# Test 1: backup.sh exists and is executable
echo "1. Checking backup.sh..."
if [[ -x "${SCRIPTS_DIR}/backup.sh" ]]; then
  echo "   ✓ backup.sh exists and is executable"
else
  echo "   ✗ backup.sh missing or not executable"
  exit 1
fi

# Test 2: restore.sh exists and is executable
echo "2. Checking restore.sh..."
if [[ -x "${SCRIPTS_DIR}/restore.sh" ]]; then
  echo "   ✓ restore.sh exists and is executable"
else
  echo "   ✗ restore.sh missing or not executable"
  exit 1
fi

# Test 3: backup-rules.json exists and is valid JSON
echo "3. Checking backup-rules.json..."
if [[ -f "${SCRIPTS_DIR}/backup-rules.json" ]]; then
  echo "   ✓ backup-rules.json exists"
  if jq empty "${SCRIPTS_DIR}/backup-rules.json" 2>/dev/null; then
    echo "   ✓ backup-rules.json is valid JSON"
  else
    echo "   ✗ backup-rules.json is not valid JSON"
    exit 1
  fi
else
  echo "   ✗ backup-rules.json missing"
  exit 1
fi

# Test 4: Dry run
echo "4. Running dry run..."
cd "${WORKSPACE_DIR}"
if "${SCRIPTS_DIR}/backup.sh" --dry-run > /dev/null 2>&1; then
  echo "   ✓ Dry run completed successfully"
else
  echo "   ✗ Dry run failed"
  exit 1
fi

# Test 5: List backups
echo "5. Listing backups..."
if "${SCRIPTS_DIR}/restore.sh" --list-backups > /dev/null 2>&1; then
  echo "   ✓ List backups completed successfully"
else
  echo "   ✗ List backups failed"
  exit 1
fi

# Test 6: Check for latest backup
echo "6. Checking for latest backup..."
if [[ -f "${WORKSPACE_DIR}/..//backups/latest.tar.gz" ]]; then
  echo "   ✓ Latest backup symlink exists"
  echo "   Target: $(readlink "${WORKSPACE_DIR}/..//backups/latest.tar.gz")"
else
  echo "   ⚠ No latest backup (expected if no backups exist yet)"
fi

echo ""
echo "=== Smoke Tests Complete ==="
echo "All critical checks passed!"