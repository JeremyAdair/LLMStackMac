# OpenClaw Ollama Model Sync

This helper keeps the explicit OpenClaw Ollama model catalog aligned with the
real models available through `ollama-gateway`.

## Why it exists

OpenClaw skips Ollama auto-discovery when `models.providers.ollama` is defined
explicitly. This stack uses an explicit provider entry so OpenClaw can reach
native host Ollama through `ollama-gateway`, which means the model list needs
to be refreshed intentionally.

## Script

- `openclaw-sync-ollama-models`

## Behavior

- Fetches `/api/tags` from `ollama-gateway` through the running stack.
- Rewrites only `models.providers.ollama.models` in
  `/config/openclaw/openclaw.json`.
- Preserves the rest of the OpenClaw config.
- Recreates the `openclaw` service by default so the UI sees the updated
  catalog immediately.

## Usage

```bash
./tools/daemon/openclaw-sync-ollama-models/openclaw-sync-ollama-models
```

Skip the restart if you only want to update the config file:

```bash
RESTART_OPENCLAW_AFTER_SYNC=false \
./tools/daemon/openclaw-sync-ollama-models/openclaw-sync-ollama-models
```
