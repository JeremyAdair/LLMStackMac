# Installation Runbook (Homelab)

This runbook describes a reliable, step-by-step installation for a fresh Linux host in a LAN-first homelab environment. It assumes you are running Docker locally and do not need any cloud services.

## Assumptions

- Host OS is Ubuntu or Debian.
- You will access the stack from devices on your LAN.
- You are not exposing this stack to the public internet.

## Prerequisites

### Supported OS

- Ubuntu 22.04 or newer
- Debian 12 or newer

### Required packages

- Docker Engine
- Docker Compose plugin
- Git

### Optional GPU notes

- GPU is not required.
- If you have an NVIDIA GPU, you can later enable the NVIDIA container runtime for Ollama, but this is optional.

### Disk and RAM guidance

- Disk: 50 GB minimum, 100 GB recommended (models and data grow quickly).
- RAM: 16 GB minimum, 32 GB recommended.

## Install Docker and Git

```bash
sudo apt update
sudo apt -y upgrade
sudo apt -y install ca-certificates curl gnupg git

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Add your user to the Docker group:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

## Repository setup

Clone the repository and change into the directory:

```bash
git clone <your-repo-url>
cd LLMStack
```

### Folder overview

- `compose/`: per-service Docker Compose files.
- `config/`: service configuration (reverse proxy, auth).
- `workspace/`: user inputs and outputs (gitignored).
- `docs/`: documentation and runbooks.

## Configuration

### Environment file

Copy the example environment file and edit it:

```bash
cp .env.example .env
```

### Required environment variables

Set the following values in `.env` before starting the stack:

- `AUTHELIA_JWT_SECRET`: random string for auth tokens.
- `AUTHELIA_SESSION_SECRET`: random string for session cookies.
- `AUTHELIA_STORAGE_ENCRYPTION_KEY`: random string for storage encryption.

### Optional environment variables

These have defaults but can be tuned later:

- `OLLAMA_BASE_URL`: internal Ollama URL.
- `QDRANT_URL`: internal Qdrant URL.
- `RAG_COLLECTION`, `RAG_EMBED_MODEL`, `RAG_VECTOR_SIZE`.
- `FLOWISE_USERNAME`, `FLOWISE_PASSWORD`.
- `OPENHANDS_BASE_PATH`.
- `GRAFANA_ROOT_URL`.
- `NODE_RED_HOST`, `NODE_RED_PORT`.
- `STT_MODEL_PATH`, `TTS_VOICE_MODEL`.

### Reverse proxy hostnames (LAN only)

This stack uses a reverse proxy on port 80. Access by LAN hostname or IP:

- `http://<host-ip>/` for Open WebUI
- `http://<host-ip>/flowise/`
- `http://<host-ip>/openhands/`
- `http://<host-ip>/grafana/`
- `http://<host-ip>/nodered/`

If you want a friendly hostname, add a DNS entry or edit your LAN device hosts file to map a name to your server IP.

### Keep secrets out of git

- Store secrets only in `.env` and `secrets/` (both are gitignored).
- Do not commit password hashes or API keys into the repo.

## Bring-up order (critical)

The recommended startup sequence is core services first, then optional tooling.

### Step 1: Start core services

```bash
./bin/llm-up
```

Check container status:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  -f compose/open-webui/docker-compose.yml \
  -f compose/qdrant/docker-compose.yml \
  -f compose/reverse-proxy/docker-compose.yml \
  -f compose/auth/docker-compose.yml \
  ps
```

Expected: core services show `Up`.

### Step 2: Verify the reverse proxy and auth gateway

Open your browser and visit:

- `http://<host-ip>/`

You should be redirected to the login page at `/authelia/`.

### Step 3: Verify Qdrant and Ollama

Check Qdrant service health (from the host):

```bash
curl -f http://localhost:6333/collections
```

Check Ollama service health:

```bash
curl -f http://localhost:11434/api/tags
```

### Step 4: Optional services

Start optional services when needed:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/flowise/docker-compose.yml \
  -f compose/monitoring/docker-compose.yml \
  -f compose/node-red/docker-compose.yml \
  up -d
```

## First-run tasks

### Pull a small Ollama model

Example:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  exec -it ollama ollama pull llama3
```

### Open WebUI and verify chat

- Open `http://<host-ip>/`
- Log in via Authelia
- Start a chat and confirm the model responds

### Open Flowise and verify Ollama connectivity

- Open `http://<host-ip>/flowise/`
- Create a simple flow with an Ollama node
- Run a test prompt

### Confirm monitoring dashboards

- Open `http://<host-ip>/grafana/`
- Log in with Grafana defaults and confirm the UI loads

## File locations

- Persistent data: `data/`
- User inputs and outputs: `workspace/`
- Service configs: `config/`

