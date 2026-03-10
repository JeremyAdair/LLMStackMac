#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../../.." && pwd)"

version="dev"
if [[ -f "${repo_root}/VERSION" ]]; then
  version="$(tr -d '[:space:]' < "${repo_root}/VERSION")"
fi

git_ref="no-git"
if git -C "${repo_root}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_ref="$(git -C "${repo_root}" rev-parse --short HEAD 2>/dev/null || echo unknown)"
fi

build_date="$(date '+%Y-%m-%d %H:%M:%S %Z')"

echo "LLMStack CLI"
echo "version: ${version}"
echo "git: ${git_ref}"
echo "built: ${build_date}"
