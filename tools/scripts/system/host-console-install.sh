#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/../../.." && pwd)"
launch_agents_dir="${HOME}/Library/LaunchAgents"
plist_path="${launch_agents_dir}/com.llmstack.host-console.plist"
label="com.llmstack.host-console"

mkdir -p "${launch_agents_dir}"

cat > "${plist_path}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${label}</string>
  <key>ProgramArguments</key>
  <array>
    <string>${repo_root}/tools/scripts/system/host-console-run.sh</string>
  </array>
  <key>KeepAlive</key>
  <true/>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>${HOME}/Library/Logs/llmstack-host-console.log</string>
  <key>StandardErrorPath</key>
  <string>${HOME}/Library/Logs/llmstack-host-console.log</string>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)" "${plist_path}" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "${plist_path}"
launchctl kickstart -k "gui/$(id -u)/${label}"

echo "Installed host console launch agent at ${plist_path}"
