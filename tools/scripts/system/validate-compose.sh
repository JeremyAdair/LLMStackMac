#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/stack-lib.sh"

layers=(data core observability admin lab)
for layer in "${layers[@]}"; do
  echo "[llmstack] Validating compose/${layer}.yml"
  docker compose --env-file "${env_file}" -p "llm-${layer}" -f "$(compose_file "${layer}")" config >/dev/null
done

echo "[llmstack] Compose validation OK"
