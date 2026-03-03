# Google Drive Setup Guide

## gog CLI is Already Installed

The `gog` CLI is already installed at `/root/openclaw-stock-home/.local/bin/gog` and is available in your `PATH`.

Verify installation:
```bash
gog --version
gog drive ls  # List files in root folder
```

## Authenticate with Google Drive

If you haven't authenticated yet, run:
```bash
gog drive ls
```

This will open a browser window for Google authentication. Follow the prompts to authorize gog to access your Google Drive.

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

**Solution**: The `gog` CLI should already be installed. Check `/root/openclaw-stock-home/.local/bin/gog`.

### Authentication error
```
Error: unable to list files
```

**Solution**: Run `gog drive ls` and authenticate with your Google account

### Permission denied
```
Error: Permission denied
```

**Solution**: Check folder permissions or use a different parent folder ID
