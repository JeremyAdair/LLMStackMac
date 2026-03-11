# Service Profiles and Startup Modes

Deprecated: this profile-based layout was replaced by multi-project layered compose files.
Use `docs/architecture.md` and `docs/stack-modes.md`.

This stack now uses layered Docker Compose projects to keep default startup focused on daily-use core services.

## Architecture by role

### Core (default startup)

- `reverse-proxy`: single web ingress and routing.
- `landing`: homepage/service links.
- `auth`: SSO and access control.
- `open-webui`: primary user interface.
- `postgres`: primary relational datastore.
- `redis`: cache/queue backing service.
- `qdrant`: vector datastore.

### Observability (optional)

- `prometheus`: metrics storage and scraping.
- `grafana`: dashboards and alert visualization.
- `blackbox-exporter`: HTTP probe metrics.
- `postgres-exporter`: PostgreSQL metrics.

### Observability Host (optional, higher trust)

- `node-exporter`: host metrics.
- `cadvisor`: container metrics.

### Admin (optional)

- `pgadmin`: PostgreSQL admin UI.
- `redisinsight`: Redis admin UI.
- `forgejo`: local Git service.

### Lab/experimental (optional)

- `flowise`
- `pdf-auto-ingest`
- `node-red`
- `openclaw`
- `openhands`
- `python-api`
- `python-toolbox`
- `stt`, `tts`, `ocr`
- `pdf-ingest`, `rag-pipeline`

## Overlap audit and decisions

- `python-api` vs `python-toolbox`:
  - Overlap is real (same image/code mount).
  - Kept separate for now because one is long-running API and one is operator shell/runtime.
  - Merge candidate: medium confidence. Defer until API surface and toolbox scripts are stabilized.
- `openclaw` vs `openhands`:
  - Both are agent-oriented lab tooling.
  - Both moved to `lab` and off by default.
  - Recommendation: run one at a time unless actively comparing.
- `landing` vs `reverse-proxy`:
  - `landing` is static content, `reverse-proxy` is routing/auth front.
  - Merge candidate exists (serve landing directly from reverse-proxy static mount), but deferred to avoid changing routing behavior during profile refactor.
- `pgadmin` and `redisinsight`:
  - Moved to `admin` profile; no longer always-on.
- `node-exporter` and `cadvisor`:
  - Split into `observability-host`; optional because they need host mounts and, for cAdvisor, Docker runtime access.

## What changed in compose

- Added layered startup modes:
  - `core`, `observability`, `admin`, `lab`, `full`.
- `./tools/bin/cli-handler/llm up full` defaults to `full` for complete bring-up.
- Reduced `reverse-proxy` `depends_on` to core web dependencies:
  - `open-webui`, `auth`, `landing`.
- Preserved all existing data volume mounts and env variable names.

## Startup commands

Daily use (core only):

```bash
./tools/bin/cli-handler/llm up full
```

Core + observability dashboards:

```bash
./tools/bin/cli-handler/llm up observability
```

Host/container runtime metrics:

```bash
./tools/bin/cli-handler/llm up observability-host
```

Admin/debug session:

```bash
./tools/bin/cli-handler/llm up admin
./tools/bin/cli-handler/llm up observability
```

Full lab session (everything):

```bash
./tools/bin/cli-handler/llm up full
```

Stop everything currently running:

```bash
./tools/bin/cli-handler/llm down all
```

## Migration notes

- No persistent storage paths changed.
- Existing named volumes remain valid.
- Existing `.env` / `.env.mac` keys remain valid.
- Optional layers stay down unless explicitly started.
- For one-command everything, use `./tools/bin/cli-handler/llm up full`.
