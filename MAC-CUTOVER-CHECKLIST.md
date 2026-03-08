# Mac Cutover Checklist (M4 Pro / Apple Silicon)

This is the practical runbook for migration day.

## 1) Preflight on Mac
1. Install Docker Desktop and start it.
2. Clone this repo.
3. Ensure helper scripts are executable (safe to run always):
   - `chmod +x bin/*`
4. Verify scripts are executable:
   - `bash -n bin/llm-up bin/first-run-mac bin/llm-check-core`
5. Create folders:
   - `./bin/first-run-mac`
6. Create env file:
   - `cp .env.mac.example .env.mac`
7. Fill required secrets in `.env.mac`:
   - `AUTHELIA_JWT_SECRET`
   - `AUTHELIA_SESSION_SECRET`
   - `AUTHELIA_STORAGE_ENCRYPTION_KEY`
   - keep `AUTH_DOMAIN=llmstack.lan`
   - keep `LANDING_HOSTNAME=llmstack.lan`

## 2) Local Hostname Setup
1. Print host entries:
   - `./bin/hosts-entries`
2. Add output to `/etc/hosts`.
3. Flush DNS cache:
   - `sudo dscacheutil -flushcache`
   - `sudo killall -HUP mDNSResponder`

## 3) Optional Image Pull Precheck
Run this before full bring-up:

```bash
docker pull openwebui/open-webui:latest
docker pull flowiseai/flowise:latest
docker pull codeberg.org/forgejo/forgejo:1.21
docker pull prom/prometheus:latest
docker pull grafana/grafana:latest
docker pull nodered/node-red:latest
docker pull postgres:15-alpine
docker pull redis:7-alpine
docker pull qdrant/qdrant:latest
docker pull redis/redisinsight:latest
```

Known unresolved image risks (may fail until we patch live):
- OpenHands image source
- STT (`whisper.cpp`) image source
- TTS (`piper`) image source

## 4) Bring Up Core Stack
Use mac helper:

```bash
./bin/llm-up
```

Notes:
- This keeps OpenHands defined but scales it to `0`.
- STT/TTS/OCR are intentionally not part of this initial path.

## 5) Smoke Test
Run:

```bash
./bin/llm-check-core
```

Expected:
- HTTPS endpoints return `200`/`302` (auth redirects are okay).
- `http://localhost:6333/collections` returns `200`.

Manual checks:
- `https://llmstack.lan/`
- `https://openwebui.llmstack.lan/`
- `https://flowise.llmstack.lan/`
- `https://forgejo.llmstack.lan/`
- `https://grafana.llmstack.lan/`
- `https://nodered.llmstack.lan/`

## 6) Data Services Check
Run:

```bash
docker compose --env-file .env.mac \
  -f compose/docker-compose.yml \
  -f compose/monitoring/docker-compose.yml \
  -f compose/node-red/docker-compose.yml \
  -f compose/postgres/docker-compose.yml \
  -f compose/redis/docker-compose.yml \
  -f compose/qdrant/docker-compose.yml \
  -f compose/redisinsight/docker-compose.yml \
  ps
```

## 7) First Debug Commands
```bash
docker compose --env-file .env.mac -f compose/docker-compose.yml -f compose/reverse-proxy/docker-compose.yml logs --tail 200 reverse-proxy
docker compose --env-file .env.mac -f compose/docker-compose.yml -f compose/auth/docker-compose.yml logs --tail 200 auth
docker compose --env-file .env.mac -f compose/docker-compose.yml -f compose/open-webui/docker-compose.yml logs --tail 200 open-webui
docker compose --env-file .env.mac -f compose/docker-compose.yml -f compose/flowise/docker-compose.yml logs --tail 200 flowise pdf-auto-ingest
```

## 8) Rollback
If cutover fails:
1. Stop stack services: `./bin/llm-down`
2. Restore the last known-good `.env.mac`.
3. Start core services and re-check health: `./bin/llm-up && ./bin/llm-check-core`
