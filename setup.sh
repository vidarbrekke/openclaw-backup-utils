#!/usr/bin/env bash
# setup.sh — Configures OpenClaw Backup Utils for first-time use
# Purpose: Automate setup for gog account, cron, and rules. Relies on gogcli-enhanced/setup.sh being run first.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_FILE="${REPO_DIR}/backup-rules.json"
DEFAULT_PARENT_ID="1b9uskrej-gjGVG-RmeaSYdPk0deUOa3R"

# Color codes for pretty output
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# Log functions (defined early so they can be used throughout)
log() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}==>${RESET} $*"; }
warn() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${YELLOW}Warning:${RESET} $*"; }
err() { echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}Error:${RESET} $*"; }

echo -e "${BOLD}== OpenClaw Backup Utils Setup ==${RESET}"

# --- Step 1: Check Dependencies ---
log "Checking dependencies..."
if ! command -v gog >/dev/null 2>&1; then
  err "gog CLI not found in PATH."
  err "Please run gogcli-enhanced/scripts/setup.sh first to install/enable gog, then rerun this script."
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  err "jq not found. Please install jq (e.g., sudo apt-get install -y jq) and rerun."
  exit 1
fi
log "Dependencies (gog, jq) found."

# --- Step 2: Detect GOG Account ---
log "Detecting GOG account configuration..."
AUTO_ACCOUNT="$(gog auth list --account auto 2>/dev/null | awk 'NR==1{print $1}' || true)"
if [[ -z "${AUTO_ACCOUNT}" ]]; then
  err "No gog account configured."
  err "Please run gogcli-enhanced/scripts/setup.sh first to set up gog authentication, then rerun this script."
  exit 1
fi
GOG_ACCOUNT="${GOG_ACCOUNT:-${AUTO_ACCOUNT}}"
log "Detected GOG account: $GOG_ACCOUNT"

# --- Step 3: Verify Non-Interactive GOG Auth ---
# We rely on GOG_KEYRING_PASSWORD being set in the environment for non-interactive commands (cron, scripts).
# It is not stored in .env.backup for security reasons.
log "Verifying non-interactive GOG auth for account: $GOG_ACCOUNT..."
if ! GOG_KEYRING_PASSWORD="${GOG_KEYRING_PASSWORD:-}" gog --account "$GOG_ACCOUNT" --no-input auth status >/dev/null 2>&1; then
  err "Non-interactive GOG auth check failed for account: $GOG_ACCOUNT."
  err "This means gog cannot authenticate without user interaction or via environment variables."
  warn "Please ensure GOG_KEYRING_PASSWORD is correctly configured in your environment for cron/scripts."
  warn "You might need to add 'export GOG_KEYRING_PASSWORD="your_password"' to your crontab environment or shell profile."
  exit 1
fi
log "Non-interactive GOG auth check passed for account: $GOG_ACCOUNT."

# --- Step 4: Persist GOG_ACCOUNT to .env.backup ---
log "Persisting GOG_ACCOUNT to ${REPO_DIR}/.env.backup (for backup.sh script to use)..."
cat > "${REPO_DIR}/.env.backup" <<EOF
GOG_ACCOUNT=${GOG_ACCOUNT}
EOF
chmod 600 "${REPO_DIR}/.env.backup"
log "Updated ${REPO_DIR}/.env.backup with GOG_ACCOUNT."

# --- Step 5: Ensure parentId in backup-rules.json ---
log "Ensuring Google Drive parentId is set in backup-rules.json..."
TMP_RULES="$(mktemp)"
jq --arg pid "$DEFAULT_PARENT_ID" '.parentId = (.parentId // $pid)' "$RULES_FILE" > "$TMP_RULES"
mv "$TMP_RULES" "$RULES_FILE"
log "Google Drive parentId ensured in ${RULES_FILE}. Defaulting to '$DEFAULT_PARENT_ID' if not explicitly set."

# --- Step 6: Install Cron Job ---
log "Installing daily cron job..."
CRON_LINE="0 3 * * * ${REPO_DIR}/backup.sh --cron --upload-google-drive"
if (crontab -l 2>/dev/null | grep -Fq -- "${CRON_LINE}"); then
  log "Cron job already exists: $CRON_LINE"
else
  (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
  log "Cron job added: $CRON_LINE"
fi

# --- Step 7: Final Instructions ---
echo
echo -e "${BOLD}Setup complete!${RESET}"
log "- Configured Account: $GOG_ACCOUNT"
log "- Cron Job: $CRON_LINE (runs daily at 03:00 UTC)"
log "- For cron job to work, ensure GOG_KEYRING_PASSWORD is set in your crontab environment:"
log "  Open crontab: 'crontab -e', then add 'GOG_KEYRING_PASSWORD="your_password_here"' on its own line before the backup command."
log "Test now: ${REPO_DIR}/backup.sh --upload-google-drive"
echo
