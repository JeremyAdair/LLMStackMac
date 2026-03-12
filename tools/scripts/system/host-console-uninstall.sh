#!/usr/bin/env bash
set -euo pipefail

plist_path="${HOME}/Library/LaunchAgents/com.llmstack.host-console.plist"
label="com.llmstack.host-console"

launchctl bootout "gui/$(id -u)" "${plist_path}" >/dev/null 2>&1 || true
rm -f "${plist_path}"

echo "Removed host console launch agent ${label}"
