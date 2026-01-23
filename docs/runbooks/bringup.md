# Bringup Runbook

This runbook walks a beginner through bringing up the LLMStack on a fresh Ubuntu install. It explains what each step does and why it matters.

## What this runbook is

A runbook is a step-by-step guide for setting up and operating a system. Use this when you want a reliable, repeatable process for first-time setup.

## Goals

- Install Docker and Docker Compose.
- Start the full LLMStack with one command.
- Learn how to start individual services and run ingestion jobs.
- Install local speech and OCR models.

## Prerequisites

- A fresh Ubuntu machine with internet access.
- A terminal session with sudo privileges.

## Step 1: Update the system

Keeping the system packages current avoids common installation errors.

```bash
sudo apt update
sudo apt -y upgrade
```

## Step 2: Install Docker Engine

Docker runs the containers that make up the stack. We install it from the official Docker repository.

```bash
sudo apt -y install ca-certificates curl gnupg
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

## Step 3: Allow your user to run Docker

By default, Docker requires root. Adding your user to the docker group lets you run Docker without sudo.

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

## Step 4: Clone the repository

This step gets the LLMStack files onto your machine.

```bash
git clone <your-repo-url>
cd LLMStack
```

## Step 5: Configure environment variables

The stack reads configuration from `.env`. Start from the example and adjust as needed.

```bash
cp .env.example .env
```

Set strong values for the authentication secrets:

- `AUTHELIA_JWT_SECRET`
- `AUTHELIA_SESSION_SECRET`
- `AUTHELIA_STORAGE_ENCRYPTION_KEY`

## Step 6: Create the workspace folders

These folders are where you drop PDFs and where the ingestion outputs are written. They are gitignored.

```bash
mkdir -p workspace/ingest workspace/processed workspace/indexed
mkdir -p workspace/audio/in workspace/audio/out
mkdir -p workspace/ocr/in workspace/ocr/out
```

## Step 7: Create the first auth user

Generate a password hash and update the user database:

```bash
docker run --rm authelia/authelia:latest authelia hash-password --password "change-me"
```

Replace the password hash for the `admin` user in `config/auth/users_database.yml`.

## Step 8: Start the full stack

This brings up all services, including the reverse proxy, UIs, databases, and optional tooling.

```bash
./bin/llm-up
```

Optional: start only the core services (Ollama, Open WebUI, Qdrant, reverse proxy):

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  -f compose/open-webui/docker-compose.yml \
  -f compose/qdrant/docker-compose.yml \
  -f compose/reverse-proxy/docker-compose.yml \
  up -d
```

## Step 9: Access the UIs

Open these URLs in your browser:

- Open WebUI: http://localhost/
- Flowise: http://localhost/flowise/
- OpenHands: http://localhost/openhands/
- Grafana: http://localhost/grafana/
- Node-RED: http://localhost/nodered/

You should be redirected to the Authelia login page before accessing protected routes.

Smoke test:

1) Open http://localhost/ and confirm you are redirected to `/authelia/`.
2) Log in with your configured user and confirm Open WebUI loads.
3) Open http://localhost/nodered/ and confirm the editor loads.

## Step 10: Download speech and OCR models

This pulls the Whisper and Piper models defined in `models/models.yml` into `data/`.

```bash
./bin/models-pull
```

Smoke test:

```bash
ls -1 data/stt/models data/tts/voices
```

## Step 11: Run PDF ingestion (optional)

Use this when you want to convert PDFs to markdown before indexing.

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/pdf-ingest/docker-compose.yml \
  run --rm pdf-ingest
```

## Step 12: Run the RAG pipeline (optional)

This reads markdown from the workspace, embeds it through Ollama, and writes vectors to Qdrant.

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/ollama/docker-compose.yml \
  -f compose/qdrant/docker-compose.yml \
  up -d

docker compose \
  -f compose/docker-compose.yml \
  -f compose/rag-pipeline/docker-compose.yml \
  run --rm rag-pipeline
```

## Step 13: Run speech-to-text (optional)

Place an audio file in `workspace/audio/in`, then run:

```bash
./bin/stt-transcribe sample.wav
```

Smoke test:

```bash
test -f workspace/audio/out/sample.txt
```

## Step 14: Run text-to-speech (optional)

```bash
./bin/tts-speak "hello world"
```

Smoke test:

```bash
test -f workspace/audio/out/tts_output.wav
```

## Step 15: Run OCR (optional)

Place an image in `workspace/ocr/in`, then run:

```bash
./bin/ocr-run sample.png
```

Smoke test:

```bash
test -f workspace/ocr/out/sample.txt
```

## Step 16: Start Node-RED (optional)

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/node-red/docker-compose.yml \
  up -d
```

## Step 17: Node-RED smoke test (optional)

1) Open the Node-RED editor.
2) Add an Inject node and a Debug node, connect them, and click Deploy.
3) Click the Inject button and confirm the message appears in the Debug sidebar.

## Step 18: Run a one-off Python job (optional)

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/python-runner/docker-compose.yml \
  run --rm python-runner python /app/main.py
```

## Step 19: Stop Node-RED (optional)

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/node-red/docker-compose.yml \
  stop node-red
```

## Step 20: Stop the stack

Use this when you want to shut everything down.

```bash
./bin/llm-down
```

## Ports

These are the default host ports exposed by the stack:

- `80` reverse proxy (routes to Open WebUI, Flowise, OpenHands)
- `11434` Ollama (optional direct access)
- `6333` Qdrant (optional direct access)
- `5432` Postgres (optional direct access)
- `6379` Redis (optional direct access)
