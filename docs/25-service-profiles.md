# Service Profiles and Startup Modes

Deprecated: this profile-based layout was replaced by multi-project layered compose files.
Use `docs/architecture.md` and `docs/stack-modes.md`.

This stack now uses Docker Compose profiles to keep default startup focused on daily-use core services.

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
- `node-exporter`: host metrics.
- `cadvisor`: container metrics.

### Observability-plus (optional)

- `blackbox-exporter`: HTTP probe metrics for endpoint uptime.
- `postgres-exporter`: deep PostgreSQL metrics.

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
- `blackbox-exporter` and `postgres-exporter`:
  - Split into `observability-plus`; optional even when baseline observability is enabled.

## What changed in compose

- Added profiles to optional services:
  - `admin`, `lab`, `observability`, `observability-plus`.
- Left core services unprofiled so `./bin/llm-up` starts only core.
- Reduced `reverse-proxy` `depends_on` to core web dependencies:
  - `open-webui`, `auth`, `landing`.
- Preserved all existing data volume mounts and env variable names.

## Startup commands

Daily use (core only):

```bash
./bin/llm-up
```

Core + observability dashboards:

```bash
./bin/llm-up --profile observability
```

Admin/debug session (core + admin + observability + deep exporters):

```bash
./bin/llm-up --profile admin --profile observability --profile observability-plus
```

Full lab session (everything):

```bash
./bin/llm-up --profile admin --profile observability --profile observability-plus --profile lab
```

Stop everything currently running:

```bash
./bin/llm-down
```

## Migration notes

- No persistent storage paths changed.
- Existing named volumes remain valid.
- Existing `.env` / `.env.mac` keys remain valid.
- Optional services will now stay down unless their profile is requested.
- If you previously expected all services on `./bin/llm-up`, use the full lab command above.
