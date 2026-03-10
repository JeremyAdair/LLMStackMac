#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
since="${SINCE:-30m}"
source "${repo_root}/tools/scripts/system/stack-lib.sh"
projects=(llm-data llm-core llm-observability llm-admin llm-lab)

if [[ "$#" -eq 0 ]]; then
  echo "Usage: llm logs <service...>"
  echo "Example: llm logs reverse-proxy auth open-webui"
  echo "Optional: SINCE=2h llm logs flowise"
  exit 1
fi

for project in "${projects[@]}"; do
  for svc in "$@"; do
    docker compose --env-file "${env_file}" -p "${project}" ps --services 2>/dev/null | grep -qx "${svc}" || continue
    echo "== ${project}/${svc} =="
    docker compose --env-file "${env_file}" -p "${project}" logs --since "${since}" -f "${svc}" || true
  done
done
