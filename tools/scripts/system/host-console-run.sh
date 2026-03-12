#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../../.." && pwd)"
port="${HOST_CONSOLE_PORT:-7682}"
title="${HOST_CONSOLE_TITLE:-LLMStack Console}"
session="${HOST_CONSOLE_TMUX_SESSION:-llmstack}"

export PATH="/opt/homebrew/bin:/usr/local/bin:${PATH}"
export TMUX_TMPDIR="${TMUX_TMPDIR:-/tmp}"

cd "${repo_root}"
exec ttyd \
  -W \
  -p "${port}" \
  -b /console \
  -H X-WEBAUTH-USER \
  -t "titleFixed=${title}" \
  /bin/zsh -lc "cd '${repo_root}' && exec tmux new-session -A -s '${session}'"
