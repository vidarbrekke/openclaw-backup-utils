# openclaw-backup-utils

Smart OpenClaw disaster recovery and backup system.

## Quick Start

### 0) One-time setup (recommended)
```bash
./setup.sh
```

This configures:
- non-interactive `gog` auth inputs for cron (`.env.backup`)
- default account wiring for uploads
- daily cron job at 03:00 UTC

### Create Backup
```bash
./backup.sh [--dry-run] [--upload-google-drive] [--cron]
```

| Option | Description |
|--------|-------------|
| `--dry-run` | Test without creating backup |
| `--upload-google-drive` | Upload backup to Google Drive (requires `gog` CLI + setup.sh auth) |
| `--cron` | Enable cron mode (cleanup old backups) |

### Restore
```bash
./restore.sh /path/to/backup.tar.gz
./restore.sh --latest  # Use most recent backup
./restore.sh --list-backups  # List available backups
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

## Google Drive Setup

The backup script uses the `gog` CLI (Google CLI for Workspace) for uploads.

`gog` is already installed at `/root/openclaw-stock-home/.local/bin/gog` and is available in your `PATH`.

To enable Google Drive uploads, authenticate with your Google account:
```bash
gog drive ls  # This will authenticate if needed
```

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
- `docs/GOOGLE_DRIVE_SETUP.md` - Google Drive setup guide

## Auth flow note (simple vs efficient)

- **Simple flow** (`gog auth add ... --manual`) is easiest and most reliable for remote servers.
- It is **not slower for daily backups** in any meaningful way.
- Auth overhead is paid once; refresh tokens are reused automatically.
- Runtime impact is minimal (small token validation/refresh only when needed).

## License

MIT
