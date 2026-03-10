# CreateDesktopIcons

This folder manages clickable Mac Mini desktop launchers.

The launchers run the real scripts in `bin/` directly:

- `LLM-Up.app` -> `./tools/bin/llm up full`
- `LLM-Down.app` -> `./tools/bin/llm down all`
- `LLM-Status.app` -> `./tools/bin/llm status`
- `LLM-Backup.app` -> `./tools/jobs/backup`
- `LLM-Doctor.app` -> `./tools/bin/llm doctor`

## One-command setup

Run from repo root:

```bash
./tools/bin/CreateDesktopIcons/llm-desktop-launchers-setup
```

## Contents

- `llm-desktop-launchers-setup`
  - Rebuilds desktop apps and applies icon artwork from `assets/icons/*.png`.
