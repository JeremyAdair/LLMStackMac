# set-up-cli

This folder contains CLI bootstrap tooling for new operators.

## Script

- `llm-cli-setup`

## What it does

- Ensures `tools/bin/cli-handler/llm` and script targets are executable.
- Creates user-level command symlinks:
  - `~/.local/bin/llm`
  - `~/.local/bin/llmstack`
- Attempts global Homebrew-bin symlinks when writable.
- Ensures `~/.local/bin` is in shell startup files.
- Validates `llm --help` and `llmstack --help`.
- Optional: rebuilds desktop launcher apps.

## Usage

```bash
./tools/bin/set-up-cli/llm-cli-setup
./tools/bin/set-up-cli/llm-cli-setup --with-desktop-icons
```
