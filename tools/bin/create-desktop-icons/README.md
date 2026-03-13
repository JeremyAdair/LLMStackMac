# create-desktop-icons

This folder manages clickable Mac Mini desktop launchers.

The launchers run the real scripts in `bin/` directly:

- `LLM-Up.app` -> `./tools/bin/cli-handler/llm up full`
- `LLM-Down.app` -> `./tools/bin/cli-handler/llm down all`
- `LLM-Status.app` -> `./tools/bin/cli-handler/llm status`
- `LLM-Backup.app` -> `./tools/jobs/backup`
- `LLM-Doctor.app` -> `./tools/bin/cli-handler/llm doctor`

## One-command setup

Run from repo root:

```bash
./tools/bin/create-desktop-icons/llm-desktop-launchers-setup
```

## Contents

- `llm-desktop-launchers-setup`
  - Rebuilds desktop apps and applies icon artwork from `assets/icons/*.png`.
