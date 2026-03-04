# Google Drive Setup Guide

## Prerequisite: gog CLI (gogcli-enhanced)

The backup script uses the `gog` CLI from [gogcli-enhanced](https://github.com/vidarbrekke/gogcli-enhanced). Install and configure it in **CLI-only** mode (no MCP/OpenClaw):

```bash
# In the gogcli-enhanced repo:
./scripts/setup.sh --cli-only
```

Then run this repo’s setup so `GOG_ACCOUNT` is written to `.env.backup` and cron is installed:

```bash
./setup.sh
```

## Authenticate with Google Drive

Authentication is handled by gogcli-enhanced. For **non-interactive** use (cron, scripts), the environment must provide the keyring password:

- **Interactive:** `gog drive ls` will use your keyring (password from shell or keyring file).
- **Cron/scripts:** Set `GOG_KEYRING_PASSWORD` or `GOG_KEYRING_PASSWORD_FILE` in the crontab environment (or in a sourced env file). See gogcli-enhanced docs and `./setup.sh` final instructions.

If you need to re-authenticate with Google:

```bash
export GOG_KEYRING_PASSWORD="your_keyring_password"   # or use GOG_KEYRING_PASSWORD_FILE
gog auth add you@gmail.com   # or use --manual on headless
gog drive ls   # verify
```

## Configure Backup Script

The backup script looks for `parentId` in `backup-rules.json`:

```json
{
  "parentId": "YOUR_GOOGLE_DRIVE_FOLDER_ID"
}
```

If not specified, it defaults to: `1b9uskrej-gjGVG-RmeaSYdPk0deUOa3R` (OpenClaw_Backups folder)

## Manual Test

```bash
# Dry run (no actual backup)
./backup.sh --dry-run --upload-google-drive

# Create backup and upload to Google Drive
./backup.sh --upload-google-drive

# Create backup, upload, and cleanup old backups
./backup.sh --cron --upload-google-drive
```

## Troubleshooting

### gog not found
```
WARNING: gog CLI not found, skipping Google Drive upload
```

**Solution:** Install gog via gogcli-enhanced: run `./scripts/setup.sh --cli-only` in the gogcli-enhanced repo, then run `./setup.sh` in this repo.

### Authentication error
```
Error: unable to list files
```
(or keyring unlock failed when run from cron)

**Solution:** Ensure `GOG_KEYRING_PASSWORD` or `GOG_KEYRING_PASSWORD_FILE` is set in the environment (e.g. in crontab for cron runs). Run `gog drive ls` interactively to verify; for headless, see gogcli-enhanced headless setup.

### Permission denied
```
Error: Permission denied
```

**Solution**: Check folder permissions or use a different parent folder ID
