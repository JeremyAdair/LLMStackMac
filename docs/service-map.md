# Service Map

| Service | Layer | Default | Storage | Notes |
|---|---|---|---|---|
| `postgres` | data | yes | `postgres_data` | primary SQL store |
| `redis` | data | yes | `redis_data` | cache/session support |
| `qdrant` | data | yes | `qdrant_data` | vector store |
| `ollama-gateway` | core | yes | none | only container path to native Ollama |
| `auth` | core | yes | `data/auth` | Authelia |
| `landing` | core | yes | config bind | landing UI |
| `reverse-proxy` | core | yes | config/tls binds | publishes `80/443` to loopback by default |
| `open-webui` | core | yes | `openwebui_data` | primary chat UI |
| `flowise` | core | yes | `flowise_data` | workflow/agent UI |
| `prometheus` | observability | no | `prometheus_data` | metrics |
| `grafana` | observability | no | `grafana_data` | dashboards |
| `postgres-exporter` | observability | no | none | DB metrics |
| `blackbox-exporter` | observability | no | config bind | probe metrics |
| `node-exporter` | observability-host | no | host mounts | higher-trust host metrics |
| `cadvisor` | observability-host | no | host/docker mounts | privileged container metrics |
| `forgejo` | admin | no | `forgejo_data` | local Git service |
| `pgadmin` | admin | no | `pgadmin_data` | Postgres UI |
| `redisinsight` | admin | no | `redisinsight_data` | Redis UI |
| `python-toolbox` | lab | no | bind mounts | FastAPI surface and operator tooling |
| `console` | lab | no | workspace bind | Authelia-protected ttyd + tmux |
| `node-red` | lab | no | `nodered_data` | automation |
| `openclaw` | lab | no | `openclaw_data` | experimental agent tooling |
| `openhands` | lab | no | `openhands_data` | coding agent UI |
| `rag-pipeline` | lab | no | `data/pdfs` bind | batch indexing job |
| `pdf-ingest` | lab | no | `data/pdfs` bind | PDF conversion job |
| `pdf-auto-ingest` | lab | no | `data/pdfs` bind | optional Flowise watcher |
| `ocr` | lab | no | `data` bind | OCR utility |
| `stt` | lab | no | `data/stt/models` bind | speech-to-text utility |
| `tts` | lab | no | `data/tts/voices` bind | text-to-speech utility |
