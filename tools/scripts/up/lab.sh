#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/../system/stack-lib.sh"
"${repo_root}/tools/scripts/system/validate-compose.sh"

ensure_shared_network

echo "[llmstack] Starting lab layer (llm-lab)"
if [[ "$#" -eq 0 ]]; then
  compose_project llm-lab lab up -d \
    python-toolbox \
    node-red \
    console \
    openclaw \
    openhands \
    rag-pipeline \
    pdf-ingest \
    ocr
else
  compose_project llm-lab lab up -d "$@"
fi

echo "[llmstack] Lab mode up"
