# Service Map

| Service | Layer | Always On | Depends On | Persistent Storage | Notes |
|---|---|---|---|---|---|
| reverse-proxy | core | Yes | auth, open-webui, flowise, landing | config bind mounts | Main ingress on 80/443 |
| auth (Authelia) | core | Yes | postgres (network dependency) | `data/auth` bind mount | SSO and authorization gate |
| open-webui | core | Yes | postgres, Ollama endpoint | `openwebui_data` | Primary user UI |
| flowise | core | Yes | qdrant, Ollama endpoint | `flowise_data`, `data/pdfs` | Visual workflow UI/API |
| landing | core | Yes | none | config bind mount | Main landing page |
| postgres | data | Yes | none | `postgres_data` | Primary SQL store |
| redis | data | Yes | none | `redis_data` | Cache/session store |
| qdrant | data | Yes | none | `qdrant_data` | Vector database |
| prometheus | observability | Optional | exporters/targets reachable | `prometheus_data` | Metrics storage |
| grafana | observability | Optional | prometheus | `grafana_data` | Dashboards and alert views |
| node-exporter | observability | Optional | none | host mount | Host metrics |
| cadvisor | observability | Optional | docker runtime | host/docker mounts | Container metrics |
| blackbox-exporter | observability | Optional | none | config bind mount | HTTP probe metrics |
| postgres-exporter | observability | Optional | postgres reachable | none | DB metrics |
| pgadmin | admin | Optional | postgres reachable | `pgadmin_data` | Postgres admin UI |
| redisinsight | admin | Optional | redis reachable | `redisinsight_data` | Redis admin UI |
| forgejo | admin | Optional | none | `forgejo_data` | Local Git service |
| python-toolbox | lab | Optional | none | bind mounts | Unified toolbox + FastAPI service (also reachable as `python-api` alias) |
| node-red | lab | Optional | none | `nodered_data` | Automation tooling |
| openclaw | lab | Optional | none | `openclaw_data` | Experimental agent gateway |
| openhands | lab | Optional | none | `openhands_data`, repos bind | Agent coding workspace |
| pdf-auto-ingest | lab | Optional | flowise reachable | `data/pdfs` bind | PDF watcher/upsert job |
| rag-pipeline | lab | Optional | qdrant, Ollama endpoint | `data/pdfs` bind | Batch indexer |
| pdf-ingest | lab | Optional | none | `data/pdfs` bind | PDF conversion job |
| ocr | lab | Optional | none | `data/ocr` bind | OCR utility |
| stt | lab | Optional | none | `data/stt/models` bind | Speech-to-text utility |
| tts | lab | Optional | none | `data/tts/voices` bind | Text-to-speech utility |
