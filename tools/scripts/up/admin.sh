#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/../system/stack-lib.sh"
"${repo_root}/tools/scripts/system/validate-compose.sh"

ensure_shared_network

echo "[llmstack] Starting admin layer (llm-admin)"
compose_project llm-admin admin up -d "$@"

echo "[llmstack] Admin mode up"
