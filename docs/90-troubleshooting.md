# Troubleshooting

Common issues and fixes for the LLMStack.

## Ports already in use

Symptoms:
- Containers fail to start due to port conflicts.

Fix:
- Check which process is using the port and stop it.

```bash
sudo lsof -i :80
sudo lsof -i :11434
```

## Reverse proxy routing issues

Symptoms:
- 404 errors or blank pages when accessing UI routes.

Fix:
- Ensure the reverse proxy is running.
- Confirm the route exists in `config/reverse-proxy/nginx.conf`.
- Restart the reverse proxy.

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/reverse-proxy/docker-compose.yml \
  restart reverse-proxy
```

## Auth gateway login problems

Symptoms:
- Redirect loops or unable to log in.

Fix:
- Verify `AUTHELIA_DOMAIN` matches the hostname you use in the browser.
- Check the secrets in `.env` are not empty.
- Confirm the user hash in `config/auth/users_database.yml` is correct.

## Container stuck in restarting

Symptoms:
- `docker ps` shows `Restarting`.

Fix:
- Inspect logs for the container.

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  logs ollama
```

## Qdrant not reachable from Flowise

Symptoms:
- Flowise fails to retrieve vectors.

Fix:
- Ensure Qdrant is running.
- Check network connectivity using service name `qdrant:6333`.

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/qdrant/docker-compose.yml \
  exec -it qdrant curl -f http://localhost:6333/collections
```

## Ollama model download or disk full

Symptoms:
- Model downloads fail or the container exits.

Fix:
- Check disk usage and free space.
- Remove unused models.

```bash
df -h
```

## Permission issues with workspace volumes

Symptoms:
- Containers cannot read or write under `workspace/`.

Fix:
- Ensure the workspace directories exist and are writable.

```bash
mkdir -p workspace/ingest workspace/processed workspace/indexed
chmod -R u+rwX workspace
```

## README not rendering

Symptoms:
- Markdown appears broken or code blocks are not closed.

Fix:
- Check for unclosed code fences in Markdown files.
- Use a Markdown linter or review recent edits.
