# Repo Structure

## Top level

```text
assets/     static images and visual assets
compose/    layer entrypoints and per-service compose assets
config/     runtime config for Nginx, Authelia, landing page, Grafana, OpenClaw
data/       runtime content and artifacts, mostly gitignored
docs/       operator and architecture docs
services/   owned application code
tools/      CLI wrappers, scripts, daemons, jobs
```

## Compose layout

Primary operator entrypoints:

- `compose/data.yml`
- `compose/core.yml`
- `compose/observability.yml`
- `compose/observability-host.yml`
- `compose/admin.yml`
- `compose/lab.yml`

Service-specific subdirectories under `compose/` hold supporting compose files, Dockerfiles, or vendor-specific layout.

## Important config paths

- `config/reverse-proxy/nginx.conf`
- `config/auth/`
- `config/landing/`
- `config/ollama-gateway/`
- `config/firewall/`

## Tools

- `tools/bin/cli-handler/llm`: main operator wrapper
- `tools/bin/git-push/`: guarded push helper
- `tools/scripts/up/`: layer bring-up
- `tools/scripts/down/`: layer shutdown
- `tools/scripts/system/`: diagnostics and host helpers

## Local-only symlinks

Operator convenience symlinks under `ollama/` can be kept local for inspection, but they should stay ignored and uncommitted.
