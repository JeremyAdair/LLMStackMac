# CLI Handler

This folder contains the primary CLI router entrypoints for LLMStack.

## Files

- `llm`: main command router and dispatcher
- `llmstack`: alias wrapper to `llm`

## Why this exists

`tools/bin/` now groups helper tools by purpose. The CLI router lives here to keep
command-routing logic separate from setup/utilities.

## Compatibility

Top-level launchers still exist:

- `tools/bin/cli-handler/llm`
- `tools/bin/cli-handler/llmstack`

Those stubs forward to this folder so existing scripts and user PATH setups do not break.
