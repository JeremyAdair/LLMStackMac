#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/../system/stack-lib.sh"
"${repo_root}/tools/scripts/system/validate-compose.sh"

ensure_shared_network

echo "[llmstack] Starting observability layer (llm-observability)"
compose_project llm-observability observability up -d "$@"

echo "[llmstack] Observability mode up"
