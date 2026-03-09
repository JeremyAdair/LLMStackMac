#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/llm-stack-lib.sh"

projects=(llm-lab llm-admin llm-observability llm-core llm-data)
layers=(lab admin observability core data)

for i in "${!projects[@]}"; do
  project="${projects[$i]}"
  layer="${layers[$i]}"
  echo "[llmstack] Stopping ${project}"
  compose_project "${project}" "${layer}" down "$@" || true
done

echo "[llmstack] All stack groups down"
