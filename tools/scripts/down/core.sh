#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/../system/stack-lib.sh"

echo "[llmstack] Stopping core layer (llm-core)"
if [[ "$#" -gt 0 ]]; then
  compose_project llm-core core down "$@" || true
else
  compose_project llm-core core down || true
fi

echo "[llmstack] Stopping data layer (llm-data)"
if [[ "$#" -gt 0 ]]; then
  compose_project llm-data data down "$@" || true
else
  compose_project llm-data data down || true
fi

echo "[llmstack] Core mode down"
