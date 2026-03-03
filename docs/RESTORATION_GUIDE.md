# OpenClaw Backup Utils - Restoring from Backup

This guide explains how to restore your OpenClaw instance from a disaster recovery backup.

## Prerequisites

- Access to the backup file (local or from Google Drive)
- SSH access to the target server
- OpenClaw installed (if fresh server)

## Step 1: Download Backup

### From Google Drive

```bash
# Get file ID from manifest or Drive UI
FILE_ID="1WtTowYgoc_mLRf79l957kvQVPz-Oglag"

# Download using mcporter or wget with cookies
# See docs for detailed download instructions
```

### From Local Backup

```bash
# Backups are at:
BACKUP_DIR="/root/openclaw-stock-home/.openclaw/backups"

# List backups:
ls -lh "${BACKUP_DIR}/"
```

## Step 2: Verify Backup

```bash
# Verify integrity before restoring
./scripts/verify-backup.sh /path/to/backup.tar.gz
```

Expected output:
```
1. Checking tar.gz integrity...
   ✓ Archive is valid
2. Checking manifest...
   ✓ Manifest exists
   ✓ Manifest is valid JSON
   Timestamp: 20260303_213303
   Excluded: 21 patterns
   Included: 14 patterns
3. Checking key files...
   ✓ workspace/SOUL.md
   ✓ workspace/MEMORY.md
   ✓ workspace/openclaw.json
   ✓ skills/router-governor/SKILL.md
```

## Step 3: Prepare Target Server

### Fresh Install

```bash
# Install OpenClaw
curl -fsSL https://openclaw.ai/install | sh

# Verify installation
openclaw status
```

### Existing Install

```bash
# Stop OpenClaw
openclaw gateway stop

# Backup current state (if not already backed up)
tar --create --gzip \
  --file=/root/openclaw-stock-home/.openclaw/backups/pre-restore-$(date +%Y%m%d).tar.gz \
  --directory=/root/openclaw-stock-home/.openclaw \
  --exclude='backups' \
  .
```

## Step 4: Restore Backup

```bash
# Extract backup
tar --extract --gzip \
  --file=/path/to/backup.tar.gz \
  --directory=/root/openclaw-stock-home/.openclaw \
  --overwrite
```

Or use the restore script:
```bash
./restore.sh /path/to/backup.tar.gz
```

## Step 5: Verify Restore

```bash
# Check key files exist
ls -la /root/openclaw-stock-home/.openclaw/workspace/SOUL.md
ls -la /root/openclaw-stock-home/.openclaw/workspace/MEMORY.md
ls -la /root/openclaw-stock-home/.openclaw/openclaw.json

# Start OpenClaw
openclaw gateway start

# Verify status
openclaw status
```

## Step 6: Test Critical Features

### Telegram Bot

```bash
# Send a message to test
echo "Test message" | mcporter call --server telegram-send --tool send --args '{"chatId":"5309173712", "text":"Test"}' --output json
```

### MCP Servers

```bash
# Check if MCP servers are running
openclaw gateway status
```

### Google Drive

```bash
# Test Drive access
mcporter call --server gog-agentic --tool drive.listFiles --args '{}' --output json
```

## Step 7: Post-Restore Tasks

### Update Environment Variables

If restoring to a new server:
```bash
# Update .env files with new server values
nano /root/openclaw-stock-home/.openclaw/workspace/.env
```

### Update OAuth Credentials

If credentials changed:
```bash
# Re-authenticate with Google
mcporter call --server gog-agentic --tool auth.login --args '{}' --output json
```

### Update Cron Jobs

If not restoring from backup:
```bash
crontab -e
# Add: 0 3 * * * /path/to/backup.sh --cron --upload-google-drive
```

## Troubleshooting

### Backup File Corrupted

```
ERROR: Backup file is corrupted or invalid
```

**Solution**: Download backup again, check checksum if available.

### Missing Key Files

```
✗ workspace/SOUL.md (missing)
```

**Solution**: Check manifest for inclusion patterns, manually restore from backup.

### Permission Errors

```
Permission denied
```

**Solution**: Run as root or fix permissions:
```bash
chown -R root:root /root/openclaw-stock-home/.openclaw
chmod -R 600 /root/openclaw-stock-home/.openclaw/workspace/.env*
```

## Resources

- `README.md` - Quick start guide
- `docs/ARCHITECTURE.md` - Technical details
- `docs/BACKUP_RULES.md` - Configuration reference
- `docs/RESTORATION_GUIDE.md` - This document

## Need Help?

1. Check `docs/` for detailed guides
2. Review `backup.log` for errors
3. Examine manifest for backup contents
4. Contact system administrator
