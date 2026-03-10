#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/../system/stack-lib.sh"

echo "[llmstack] Stopping observability layer (llm-observability)"
if [[ "$#" -gt 0 ]]; then
  compose_project llm-observability observability down "$@" || true
else
  compose_project llm-observability observability down || true
fi

echo "[llmstack] Observability mode down"
