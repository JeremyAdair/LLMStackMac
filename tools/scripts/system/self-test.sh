#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../../.." && pwd)"
llm="${repo_root}/tools/bin/cli-handler/llm"

ok() { echo "OK   $*"; }
warn() { echo "WARN $*"; }
err() { echo "ERR  $*"; }

failures=0

check_exec() {
  local path="$1"
  if [[ -x "${path}" ]]; then
    ok "${path}"
  else
    err "missing/non-executable: ${path}"
    failures=$((failures + 1))
  fi
}

echo "== LLM CLI self-test =="
echo "repo: ${repo_root}"
echo

check_exec "${llm}"
check_exec "${repo_root}/tools/scripts/up/core.sh"
check_exec "${repo_root}/tools/scripts/down/core.sh"
check_exec "${repo_root}/tools/scripts/status/show.sh"
check_exec "${repo_root}/tools/scripts/logs/show.sh"
check_exec "${repo_root}/tools/scripts/models/pull.sh"
check_exec "${repo_root}/tools/scripts/system/doctor.sh"
check_exec "${repo_root}/tools/scripts/system/validate-compose.sh"

echo
for layer in data core observability admin lab; do
  if [[ -f "${repo_root}/compose/${layer}.yml" ]]; then
    ok "compose/${layer}.yml"
  else
    err "missing compose/${layer}.yml"
    failures=$((failures + 1))
  fi
done

echo
if "${llm}" --help >/dev/null 2>&1; then
  ok "llm --help"
else
  err "llm --help failed"
  failures=$((failures + 1))
fi

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    ok "docker reachable"
  else
    warn "docker present but not reachable in this shell"
  fi
else
  warn "docker not found in PATH"
fi

echo
if [[ "${failures}" -eq 0 ]]; then
  ok "self-test passed"
else
  err "self-test found ${failures} hard issue(s)"
  exit 1
fi
