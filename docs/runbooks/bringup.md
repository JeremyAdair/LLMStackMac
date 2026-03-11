# Bringup Runbook

This is the shortest reliable bringup path for the current macOS stack.

## 1. Configure env and auth files

```bash
cd ~/llmstackmac
cp .env.mac.example .env.mac
cp config/auth/users_database.example.yml config/auth/users_database.yml
```

Fill in the required secrets in `.env.mac`.

## 2. Prepare hostnames

```bash
./tools/bin/create-host-entries/llm-hosts-update --print
```

Add the printed lines to `/etc/hosts`, then flush DNS:

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

## 3. Point host Ollama at the real models store

If your models live on external storage:

```bash
./tools/bin/cli-handler/llm ollama-models-path /Volumes/LLM_DATA/ollama/models
```

## 4. Start core

```bash
./tools/bin/cli-handler/llm up core
```

## 5. Validate

```bash
./tools/bin/cli-handler/llm doctor
./tools/bin/cli-handler/llm status
ollama list
```

## 6. Open the stack

- `https://llmstack.lan/`
- `https://openwebui.llmstack.lan/`
- `https://flowise.llmstack.lan/`

## 7. Optional layers

```bash
./tools/bin/cli-handler/llm up observability
./tools/bin/cli-handler/llm up admin
./tools/bin/cli-handler/llm up lab
```

## Notes

- Native Ollama is expected on macOS.
- Containers should only reach Ollama through `ollama-gateway`.
- Published ports bind to loopback by default.
