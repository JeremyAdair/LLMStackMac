# Bringup Runbook

This runbook walks a beginner through bringing up the LLMStack on a fresh Ubuntu install. It explains what each step does and why it matters.

## What this runbook is

A runbook is a step-by-step guide for setting up and operating a system. Use this when you want a reliable, repeatable process for first-time setup.

## Goals

- Install Docker and Docker Compose.
- Start the full LLMStack with one command.
- Learn how to start individual services and run ingestion jobs.

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

## Step 6: Create the workspace folders

These folders are where you drop PDFs and where the ingestion outputs are written. They are gitignored.

```bash
mkdir -p workspace/ingest workspace/processed workspace/indexed
```

## Step 7: Start the full stack

This brings up all services, including the reverse proxy, UIs, databases, and optional tooling.

```bash
./bin/llm-up
```

## Step 8: Access the UIs

Open these URLs in your browser:

- Open WebUI: http://localhost/
- Flowise: http://localhost/flowise/
- OpenHands: http://localhost/openhands/

## Step 9: Run PDF ingestion (optional)

Use this when you want to convert PDFs to markdown before indexing.

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/pdf-ingest/docker-compose.yml \
  run --rm pdf-ingest
```

## Step 10: Run the RAG pipeline (optional)

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

## Step 11: Stop the stack

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
- `9090` Prometheus (optional direct access)
- `3001` Grafana (optional direct access)
