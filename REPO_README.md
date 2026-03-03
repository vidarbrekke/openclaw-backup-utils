# OpenClaw Backup Utils

## Files

```
openclaw-backup-utils/
├── backup.sh              # Main backup script (executable)
├── restore.sh             # Restore script (executable)
├── backup-rules.json      # Configuration (exclusions/inclusions)
├── cron.example           # Example crontab entry
├── README.md              # Quick start guide
├── docs/                  # Documentation
│   ├── ARCHITECTURE.md
│   ├── BACKUP_RULES.md
│   └── RESTORATION_GUIDE.md
├── tests/                 # Tests
│   ├── smoke.test.sh
│   └── README.md
├── scripts/               # Helpers
│   └── verify-backup.sh
└── .gitignore
```

## Quick Start

### Create Backup

```bash
./backup.sh [--dry-run] [--upload-google-drive]
```

### Restore

```bash
./restore.sh /path/to/backup.tar.gz
./restore.sh --latest  # Use most recent backup
```

### Verify Backup

```bash
./scripts/verify-backup.sh /path/to/backup.tar.gz
```

### List Backups

```bash
./restore.sh --list-backups
```

## Configuration

Edit `backup-rules.json` to customize:
- Add/remove exclusion patterns
- Add/remove inclusion patterns
- Configure retention (max backups, min age)

## Cron Setup

Add to crontab for daily backups at 03:00:

```bash
echo "0 3 * * * /path/to/backup.sh --cron --upload-google-drive" | crontab -
```

## Documentation

- `README.md` - Quick start
- `docs/ARCHITECTURE.md` - Technical design
- `docs/BACKUP_RULES.md` - Pattern reference
- `docs/RESTORATION_GUIDE.md` - Detailed restore guide

## Testing

```bash
./tests/smoke.test.sh
```

## License

MIT