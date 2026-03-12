#!/usr/bin/env bash
set -euo pipefail

label="com.llmstack.host-console"

launchctl print "gui/$(id -u)/${label}" 2>/dev/null || echo "launch agent not loaded"
echo
lsof -nP -iTCP:7682 -sTCP:LISTEN || true
