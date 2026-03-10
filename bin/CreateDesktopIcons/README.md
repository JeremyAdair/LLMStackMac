# CreateDesktopIcons

This folder manages clickable Mac Mini desktop launchers.

The launchers run the real scripts in `bin/` directly:

- `LLM-Up.app` -> `./bin/llm-up`
- `LLM-Down.app` -> `./bin/llm-down`
- `LLM-Status.app` -> `./bin/llm-status`
- `LLM-Backup.app` -> `./bin/Backup/llm-backup`
- `LLM-Doctor.app` -> `./bin/llm-doctor`

## One-command setup

Run from repo root:

```bash
./bin/CreateDesktopIcons/llm-desktop-launchers-setup
```

## Contents

- `llm-desktop-launchers-setup`
  - Rebuilds desktop apps and applies icon artwork from `assets/icons/*.png`.
