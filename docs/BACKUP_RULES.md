# Backup Rules Reference

This document explains the `backup-rules.json` configuration format.

## Overview

`backup-rules.json` defines what files to **include** and **exclude** from backups.

## Structure

```json
{
  "exclusions": [
    { "pattern": "glob-pattern", "reason": "explanation" }
  ],
  "inclusions": [
    { "pattern": "glob-pattern", "reason": "explanation" }
  ],
  "retention": {
    "maxBackups": 30,
    "minAgeDays": 7
  }
}
```

## Exclusion Patterns

| Pattern | Matches | Reason |
|---------|---------|--------|
| `**/node_modules/**` | All `node_modules` directories | Reinstallable via npm/pnpm |
| `**/.git/**` | All `.git` directories | Version-controlled code |
| `**/build/**` | All `build` directories | Compiled outputs |
| `**/dist/**` | All `dist` directories | Compiled outputs |
| `**/*.test.ts` | All test files | Recreate from source |
| `**/*.spec.ts` | All spec files | Recreate from source |
| `**/*.log` | All log files | Recreated on next run |

## Inclusion Patterns

| Pattern | Matches | Reason |
|---------|---------|--------|
| `**/*.md` | All Markdown files | Documentation - unique knowledge |
| `**/.env` | Current environment config | Secrets/keys |
| `**/.env.example` | Environment templates | Configuration reference |
| `**/credentials*.json` | Credential files | OAuth tokens |
| `**/openclaw.json` | OpenClaw config | Instance setup |
| `**/skills/**/*` | Custom skills | Unique implementations |
| `**/scripts/**/*` | Automation scripts | Unique workflows |
| `**/repositories/**/*` | Repositories | Business logic |
| `**/memory/**/*` | Memory files | Assistant state |

## Retention Policy

| Field | Default | Description |
|-------|---------|-------------|
| `maxBackups` | 30 | Maximum number of backups to keep |
| `minAgeDays` | 7 | Minimum age (days) before deletion |

## Glob Pattern Syntax

- `*` - Matches any characters (excluding `/`)
- `**` - Matches any characters (including `/`)
- `?` - Matches single character
- `[]` - Match one of characters
- `!` - Negation (in `exclusions`)

### Examples

| Pattern | Matches |
|---------|---------|
| `*.log` | `app.log`, `error.log` |
| `**/*.test.ts` | `src/test.test.ts`, `lib/utils.test.ts` |
| `public/opencv*.js` | `public/opencv-4.10.0.js`, `public/opencv.js` |
| `config/{prod,dev}.json` | `config/prod.json`, `config/dev.json` |

## Adding New Patterns

### Add Exclusion

```json
{
  "exclusions": [
    { "pattern": "**/testimg/**", "reason": "test images" }
  ]
}
```

### Add Inclusion

```json
{
  "inclusions": [
    { "pattern": "**/.pi/**/*", "reason": "personal pi data" }
  ]
}
```

### Change Retention

```json
{
  "retention": {
    "maxBackups": 10,
    "minAgeDays": 14
  }
}
```

## Best Practices

1. **Be specific with exclusions** - `**/node_modules/**` is safer than `node_modules`
2. **Document reasons** - helps future-you understand why something is excluded
3. **Test changes** - use `./backup.sh --dry-run` before running actual backup
4. **Review manifests** - check `manifest.json` to verify patterns worked
