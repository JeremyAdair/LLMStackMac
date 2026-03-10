#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/../system/stack-lib.sh"

echo "[llmstack] Stopping admin layer (llm-admin)"
if [[ "$#" -gt 0 ]]; then
  compose_project llm-admin admin down "$@" || true
else
  compose_project llm-admin admin down || true
fi

echo "[llmstack] Admin mode down"
