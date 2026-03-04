#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_FILE="${REPO_DIR}/backup-rules.json"
DEFAULT_PARENT_ID="1b9uskrej-gjGVG-RmeaSYdPk0deUOa3R"

echo "== OpenClaw Backup Utils Setup =="

if ! command -v gog >/dev/null 2>&1; then
  echo "ERROR: gog CLI not found in PATH."
  echo "Install/enable gog first, then rerun."
  exit 1
fi

# Account selection (prefer actual gog config)
# We assume gog CLI is already configured via gogcli-enhanced/scripts/setup.sh
AUTO_ACCOUNT="$(gog auth list --account auto 2>/dev/null | awk 'NR==1{print $1}' || true)"
if [[ -z "${AUTO_ACCOUNT}" ]]; then
  echo "ERROR: No gog account configured. Please run gogcli-enhanced/scripts/setup.sh first."
  exit 1
fi
GOG_ACCOUNT="${GOG_ACCOUNT:-${AUTO_ACCOUNT}}"

# Keyring password (read from environment if set, otherwise assume user has it configured)
# We expect GOG_KEYRING_PASSWORD to be available if gog was set up for non-interactive use.
# The backup.sh script will explicitly try to use it if set, if not, gog will fail auth.
# No need to prompt here again, as that was handled by gogcli-enhanced/scripts/setup.sh

# Validate auth non-interactively
# Test with a known password if environment var is not set
if ! GOG_KEYRING_PASSWORD="${GOG_KEYRING_PASSWORD:-}" gog --account "$GOG_ACCOUNT" --no-input auth status >/dev/null 2>&1; then
  echo "Auth check failed. Try running:"
  echo "  gog auth add ${GOG_ACCOUNT} --manual"
  exit 1
fi

# Persist local env file for backup script
cat > "${REPO_DIR}/.env.backup" <<EOF
GOG_ACCOUNT=${GOG_ACCOUNT}
GOG_KEYRING_PASSWORD=${GOG_KEYRING_PASSWORD}
EOF
chmod 600 "${REPO_DIR}/.env.backup"

# Ensure parentId exists in rules file
if command -v jq >/dev/null 2>&1; then
  TMP="$(mktemp)"
  jq --arg pid "$DEFAULT_PARENT_ID" '.parentId = (.parentId // $pid)' "$RULES_FILE" > "$TMP"
  mv "$TMP" "$RULES_FILE"
fi

# Install cron
CRON_LINE="0 3 * * * ${REPO_DIR}/backup.sh --cron --upload-google-drive"
( crontab -l 2>/dev/null | grep -v "openclaw-backup-utils/backup.sh"; echo "$CRON_LINE" ) | crontab -

echo "Setup complete."
echo "- Account: $GOG_ACCOUNT"
echo "- Env file: ${REPO_DIR}/.env.backup"
echo "- Cron: $CRON_LINE"
echo "Test now: ${REPO_DIR}/backup.sh --upload-google-drive"