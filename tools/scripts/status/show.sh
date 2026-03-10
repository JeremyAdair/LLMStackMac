#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "$0")" && pwd)/../system/stack-lib.sh"

projects=(llm-data llm-core llm-observability llm-admin llm-lab)

for i in "${!projects[@]}"; do
  project="${projects[$i]}"
  echo ""
  echo "=== ${project} ==="
  if docker ps -a --filter "label=com.docker.compose.project=${project}" --format '{{.Names}}' | grep -q .; then
    printf '%-36s %-20s %-30s %s\n' "NAME" "SERVICE" "STATUS" "PORTS"
    docker ps -a \
      --filter "label=com.docker.compose.project=${project}" \
      --format '{{.Names}}\t{{.Label "com.docker.compose.service"}}\t{{.Status}}\t{{.Ports}}' \
      | sort \
      | awk -F '\t' '{printf "%-36s %-20s %-30s %s\n", $1, $2, $3, $4}'
  else
    echo "No containers."
  fi
done
