# Installation

This repo is currently optimized for macOS with Docker Desktop and native Ollama.

## Prerequisites

- macOS with Docker Desktop installed and running
- Homebrew
- `ollama` installed on the host
- repo cloned to a writable path
- local hostnames mapped in `/etc/hosts`

## Initial setup

```bash
cd ~/llmstackmac
cp .env.mac.example .env.mac
cp config/auth/users_database.example.yml config/auth/users_database.yml
```

Set required secrets in `.env.mac`:

- `AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET`
- `AUTHELIA_SESSION_SECRET`
- `AUTHELIA_STORAGE_ENCRYPTION_KEY`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_DB`
- `OPENWEBUI_DATABASE_URL`
- `OPENWEBUI_OAUTH_CLIENT_SECRET`
- `PGADMIN_DEFAULT_EMAIL`
- `PGADMIN_DEFAULT_PASSWORD`

## Hosts entries

Print the recommended host entries:

```bash
./tools/bin/create-host-entries/llm-hosts-update --print
```

Add them to `/etc/hosts`, then flush macOS DNS:

```bash
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

## Host Ollama

Install Ollama with Homebrew if needed, then point it at the external drive if you use one:

```bash
./tools/bin/cli-handler/llm ollama-models-path /Volumes/LLM_DATA/ollama/models
```

That command updates `launchctl`, restarts the Homebrew Ollama service, and verifies the API.

Important:

- Containers should use `OLLAMA_BASE_URL=http://ollama-gateway:11434`
- Only `ollama-gateway` should know `OLLAMA_UPSTREAM_URL=http://host.docker.internal:11434`

## Start the stack

Daily-use stack:

```bash
./tools/bin/cli-handler/llm up core
```

Everything:

```bash
./tools/bin/cli-handler/llm up full
```

## First checks

```bash
./tools/bin/cli-handler/llm doctor
./tools/bin/cli-handler/llm status
ollama list
```

Then open:

- `https://llmstack.lan/`
- `https://openwebui.llmstack.lan/`

Expect a self-signed certificate warning on first visit unless you trust the dev cert locally.
