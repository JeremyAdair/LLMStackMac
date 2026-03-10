#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

resolve_env_file() {
  if [[ -n "${LLMSTACK_ENV_FILE:-}" && -f "${LLMSTACK_ENV_FILE}" ]]; then
    printf '%s' "${LLMSTACK_ENV_FILE}"
  elif [[ -f "${repo_root}/.env.mac" ]]; then
    printf '%s' "${repo_root}/.env.mac"
  elif [[ -f "${repo_root}/.env" ]]; then
    printf '%s' "${repo_root}/.env"
  else
    printf '%s' "${repo_root}/.env.example"
  fi
}

env_file="$(resolve_env_file)"

ensure_shared_network() {
  if ! docker network inspect llm-shared >/dev/null 2>&1; then
    echo "[llmstack] Creating shared network llm-shared"
    docker network create llm-shared >/dev/null
  fi
}

compose_file() {
  printf '%s/compose/%s.yml' "${repo_root}" "$1"
}

compose_project() {
  local project="$1"
  local layer="$2"
  shift 2
  docker compose --env-file "${env_file}" -p "${project}" -f "$(compose_file "${layer}")" "$@"
}
