# Google Drive Setup Guide

## Install gdrive CLI

```bash
# Download and install gdrive CLI
wget https://github.com/gdrive-org/gdrive/releases/download/2.1.1/gdrive-linux-x64 -O /usr/local/bin/gdrive && chmod +x /usr/local/bin/gdrive

# Verify installation
gdrive about
```

## Authenticate with Google Drive

```bash
# Run gdrive to start authentication
gdrive about

# This will open a browser window for Google authentication
# Follow the prompts to authorize gdrive to access your Google Drive
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

### gdrive not found
```
ERROR: gdrive CLI not found
```

**Solution**: Install gdrive CLI (see above)

### Authentication error
```
Error: Unable to list about
```

**Solution**: Run `gdrive about` and authenticate with your Google account

### Permission denied
```
Error: Permission denied
```

**Solution**: Check folder permissions or use a different parent folder ID
