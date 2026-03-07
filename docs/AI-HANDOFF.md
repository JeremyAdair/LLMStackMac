# AI Handoff Context

If you are the next AI/helper on this repo, start here before changing anything.

## Current state
- This repo is actively migrating from Windows Docker host -> macOS Apple Silicon.
- Changes are intentionally pragmatic/homelab style.
- Windows compatibility is still important; do not rip out Windows behavior unless requested.

## Fast triage commands
If scripts are not executable after clone:
```bash
chmod +x bin/*
```

Then run:

```bash
./bin/llm-status
./bin/llm-doctor
./bin/llm-check-core
```

## Real logs (live)
```bash
SINCE=2h ./bin/llm-logs reverse-proxy auth open-webui flowise
SINCE=2h ./bin/llm-logs forgejo postgres redis qdrant
```

## Incident snapshot bundle
```bash
./bin/llm-debug-bundle
```

Output path:
- `debug-bundles/<timestamp>/`

Includes:
- rendered compose config
- docker info/version
- project `ps`
- 2h logs for core services

## Known risk areas
- OpenHands image source
- STT image source (`whisper.cpp`)
- TTS image source (`piper`)
- local TLS trust in browser on macOS
- port conflicts on new host

## Migration docs
- `MAC-CUTOVER-CHECKLIST.md`
- `migration-notes.md`
- `docs/90-troubleshooting.md`

## Guardrails
- Prefer minimal reversible edits.
- Keep hostnames and reverse-proxy flow stable unless explicitly asked.
- Use env overrides and compose overlays over hard rewrites.
