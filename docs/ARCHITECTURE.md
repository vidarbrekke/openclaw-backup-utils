# Architecture

This document describes the technical design of the OpenClaw Backup Utils.

## Components

```
openclaw-backup-utils/
├── backup.sh              # Main backup orchestrator
├── restore.sh             # Restore orchestrator
├── backup-rules.json      # Configuration (exclusions/inclusions)
├── cron.example           # Example crontab entry
├── scripts/verify-backup.sh  # Helper to validate backups
└── docs/                  # Documentation
```

## Backup Process

1. **Load Rules**: Read `backup-rules.json` for inclusion/exclusion patterns
2. **Generate Manifest**: Create JSON manifest with backup metadata
3. **Create Archive**: Use `tar` with exclusions
4. **Verify Integrity**: Confirm backup is valid
5. **Upload (Optional)**: If `--upload-google-drive`, upload to Drive
6. **Cleanup**: Remove old backups per retention policy

## Restore Process

1. **Load Backup**: Read backup file + manifest
2. **Verify Integrity**: Confirm backup is valid
3. **Backup Current State**: Create pre-restore snapshot
4. **Extract Archive**: Restore to `/root/openclaw-stock-home/.openclaw`
5. **Verify Files**: Check key files exist
6. **Provide Next Steps**: Guidance for post-restore

## Configuration

### backup-rules.json

```json
{
  "exclusions": [
    { "pattern": "**/node_modules/**", "reason": "reinstallable" }
  ],
  "inclusions": [
    { "pattern": "**/*.md", "reason": "documentation" }
  ],
  "retention": {
    "maxBackups": 30,
    "minAgeDays": 7
  }
}
```

### Pattern Syntax

- `**/node_modules/**` - Match any directory named `node_modules`
- `*.test.ts` - Match test files
- `public/opencv*.js` - Match files starting with `opencv`

## Security

- Backups include `.env` files - store securely
- Manifests are JSON - non-sensitive metadata only
- No secrets logged by default

## Performance

- Backups are ~36MB (compressed)
- Exclusions reduce size by ~80% vs full backup
- Tar extraction is O(n) where n = files included

## Error Handling

- Non-zero exit on failure
- Log files at `backups/backup.log`
- Pre-restore snapshot on restore
