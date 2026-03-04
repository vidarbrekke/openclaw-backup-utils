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

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ==>${RESET} $*"; }
warn() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${YELLOW}Warning:${RESET} $*"; }
err() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}Error:${RESET} $*"; }

# Account selection (prefer actual gog config)
# We assume gog CLI is already configured via gogcli-enhanced/scripts/setup.sh
AUTO_ACCOUNT="$(gog auth list --account auto 2>/dev/null | awk 'NR==1{print $1}' || true)"
if [[ -z "${AUTO_ACCOUNT}" ]]; then
  echo "ERROR: No gog account configured. Please run gogcli-enhanced/scripts/setup.sh first to set up gog auth."
  exit 1
fi
GOG_ACCOUNT="${GOG_ACCOUNT:-${AUTO_ACCOUNT}}"

# Validate auth non-interactively using the detected account.
# For non-interactive (cron) usage, GOG_KEYRING_PASSWORD must be in the environment where backup.sh runs.
log "Verifying non-interactive GOG auth for account: $GOG_ACCOUNT..."
if ! gog --account "$GOG_ACCOUNT" --no-input auth status >/dev/null 2>&1; then
  echo "Auth check failed for account: $GOG_ACCOUNT."
  echo "Please ensure non-interactive authentication is properly set up for gog CLI."
  echo "Run gogcli-enhanced/scripts/setup.sh and ensure GOG_KEYRING_PASSWORD is correctly configured in your environment."
  exit 1
fi
log "GOG auth check passed for account: $GOG_ACCOUNT."

# Persist local env file for backup script (only GOG_ACCOUNT)
# GOG_KEYRING_PASSWORD should be set securely in the execution environment (e.g., cron table)
cat > "${REPO_DIR}/.env.backup" <<EOF
GOG_ACCOUNT=${GOG_ACCOUNT}
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
log "- Account: $GOG_ACCOUNT"
log "- Env file: ${REPO_DIR}/.env.backup (contains GOG_ACCOUNT)"
log "- Cron: $CRON_LINE"
log "Test now: ${REPO_DIR}/backup.sh --upload-google-drive"