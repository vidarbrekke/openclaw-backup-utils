# openclaw-backup-utils

Smart OpenClaw disaster recovery and backup system.

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

### List Backups
```bash
./restore.sh --list-backups
```

## What's Backed Up

- **Identity**: `SOUL.md`, `USER.md`, `AGENTS.md`, `MEMORY.md`
- **Config**: `openclaw.json`, `.env.*`, `router-governor/SKILL.md`
- **Telegram**: Bot token, `bindings`, `credentials.json`
- **Skills**: `skills/` directory (custom implementations)
- **Scripts**: `scripts/` directory (automation workflows)
- **Repositories**: `MK-MCP/`, `photonest/`, etc.
- **Memory**: `memory/` directory (assistant state)

## What's Excluded (Restorable)

- `node_modules/`, `.git/` - reinstall via npm/pnpm/git
- `build/`, `dist/` - rebuild via `npm run build`
- Test artifacts - regenerate via `npm test`
- Logs - recreated on next run

## Configuration

Edit `backup-rules.json` to customize:
- Add/remove exclusion patterns
- Add/remove inclusion patterns
- Configure retention (max backups, min age)

## Cron Setup

Add to crontab for daily backups at 03:00:
```
0 3 * * * /path/to/openclaw-backup-utils/backup.sh --cron --upload-google-drive
```

## Documentation

- `docs/ARCHITECTURE.md` - Technical design
- `docs/BACKUP_RULES.md` - Pattern reference
- `docs/RESTORATION_GUIDE.md` - Detailed restore procedure

## License

MIT
