#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/llm-stack-lib.sh"

projects=(llm-data llm-core llm-observability llm-admin llm-lab)
layers=(data core observability admin lab)

for i in "${!projects[@]}"; do
  project="${projects[$i]}"
  layer="${layers[$i]}"
  echo ""
  echo "=== ${project} ==="
  compose_project "${project}" "${layer}" ps || true
done
