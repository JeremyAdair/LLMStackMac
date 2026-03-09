#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/llm-stack-lib.sh"

"${repo_root}/scripts/llm-validate-compose.sh"

ensure_shared_network

echo "[llmstack] Starting data layer (llm-data)"
compose_project llm-data data up -d

echo "[llmstack] Starting core layer (llm-core)"
compose_project llm-core core up -d

echo "[llmstack] Core mode up"
