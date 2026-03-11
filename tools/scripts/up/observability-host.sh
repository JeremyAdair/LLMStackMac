#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/../system/stack-lib.sh"
"${repo_root}/tools/scripts/system/validate-compose.sh"

ensure_shared_network

echo "[llmstack] Starting host observability layer (llm-observability-host)"
compose_project llm-observability-host observability-host up -d "$@"

echo "[llmstack] Host observability mode up"
