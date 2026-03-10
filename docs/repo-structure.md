# Repo Structure

## Top-level layout

```text
LLMStackMac/
  assets/        # Static media only (images/icons/backgrounds)
  compose/       # Layered compose entrypoints + per-service compose assets
  config/        # Runtime/service configuration and provisioning
  data/          # Persistent runtime state and pipeline artifacts
  services/      # Owned service code/build contexts we maintain
  tools/         # Operator tooling (CLI, scripts, daemons, jobs)
  docs/          # Documentation
  prompts/       # Prompt assets
  eval/          # Evaluation artifacts
```

## Tools conventions

```text
tools/
  bin/           # Human-invoked commands (llm <command>, ...)
  scripts/       # One-off helper/maintenance scripts
  daemon/        # Continuous/looping scripts
  jobs/          # Batch/scheduled jobs (backup/restore checks, salvage, ...)
```

## Services conventions

- `services/` contains owned implementation code and Docker build contexts.
- Current owned service code:
  - `services/python-toolbox/`
- Third-party services that are image/config driven remain under `compose/` + `config/` and are not forced into `services/`.

## Config vs assets vs data

- `config/`: service-facing configuration (Traefik, Grafana provisioning, Authelia, landing site files when served as configured static content).
- `assets/`: visual/media resources only (icons, backgrounds, screenshots).
- `data/`: runtime state and artifacts; keep structure tracked with `.gitkeep`, not payloads.

## Data pipeline conventions

```text
data/
  pdfs/
    ingest-dropzone/
    processed/
      original/
      rawtext/
      json/
      chunk/
    failed/
  ocr/
    ingest-dropzone/
    processed/
      rawtext/
      json/
      chunk/
    failed/
  stt/
  tts/
```

## Compose layering

- `compose/data.yml`
- `compose/core.yml`
- `compose/observability.yml`
- `compose/admin.yml`
- `compose/lab.yml`

These are the primary operator entrypoints and are wrapped by `tools/bin/llm-*` and `tools/scripts/llm-*`.
