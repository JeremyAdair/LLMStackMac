# Troubleshooting

## First commands

```bash
./tools/bin/cli-handler/llm status
./tools/bin/cli-handler/llm doctor
SINCE=2h ./tools/bin/cli-handler/llm logs reverse-proxy auth open-webui flowise
./tools/bin/cli-handler/llm debug-bundle
```

## Open WebUI has no models

Check these in order:

```bash
ollama list
launchctl getenv OLLAMA_MODELS
docker exec llm-core-open-webui-1 sh -lc 'curl -sS http://ollama-gateway:11434/api/tags'
```

If host Ollama is using the wrong models directory, reset it:

```bash
./tools/bin/cli-handler/llm ollama-models-path /Volumes/LLM_DATA/ollama/models
```

## Reverse proxy unreachable from another machine

By default, `80`, `443`, and `2222` bind to `127.0.0.1`.

Check:

```bash
grep -n 'HOST_BIND_IP' .env.mac .env.mac.example 2>/dev/null
```

If you want Tailscale or LAN access later, change the bind strategy intentionally and pair it with host firewall policy.

## Ollama works on host but not in containers

Check the gateway path:

```bash
docker exec llm-core-open-webui-1 sh -lc 'curl -i http://ollama-gateway:11434/api/version'
docker exec llm-core-open-webui-1 sh -lc 'curl -i http://ollama-gateway:11434/api/tags'
```

Remember:

- `/api/pull` is intentionally blocked by the gateway
- only intended services should be on `llm-ollama-access`

## Console issues

If `/console/` loads but the terminal session looks wrong, check the lab console container:

```bash
./tools/bin/cli-handler/llm up lab console
docker logs llm-lab-console-1
```

The console should start `tmux new-session -A -s llmstack`.

## Auth problems

Check:

- required secrets in `.env.mac`
- `config/auth/users_database.yml`
- `config/reverse-proxy/nginx.conf`

Then recreate core:

```bash
./tools/bin/cli-handler/llm up core
```
