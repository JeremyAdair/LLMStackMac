#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/llm-stack-lib.sh"

"${repo_root}/scripts/llm-validate-compose.sh"

ensure_shared_network

echo "[llmstack] Starting lab layer (llm-lab)"
# Keep default lab start reliable by excluding media utility images that are
# frequently unavailable/tag-volatile. Pass explicit service names/args to override.
if [[ "$#" -eq 0 ]]; then
  compose_project llm-lab lab up -d \
    python-toolbox \
    node-red \
    openclaw \
    openhands \
    pdf-auto-ingest \
    rag-pipeline \
    pdf-ingest \
    ocr
else
  compose_project llm-lab lab up -d "$@"
fi

echo "[llmstack] Lab mode up"
