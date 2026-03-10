#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
env_file="${repo_root}/.env.mac"
if [[ ! -f "${env_file}" && -f "${repo_root}/.env" ]]; then
  env_file="${repo_root}/.env"
fi

docker compose --env-file "${env_file}" -p llm-lab -f "${repo_root}/compose/lab.yml" run --rm pdf-ingest "$@"
