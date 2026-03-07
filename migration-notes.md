# Migration Notes (Phase 1)

## What changed
- Forgejo server domain settings are now env-driven with current defaults preserved:
  - `FORGEJO_DOMAIN`
  - `FORGEJO_ROOT_URL`
  - `FORGEJO_SSH_DOMAIN`
- Added these variables to `.env.example` and `.env.mac.example`.

## Why
- Removes hard-coded hostname assumptions from compose for easier Windows/macOS migration.
- Keeps current behavior by default (`forgejo.llmstack.lan`) unless overridden.

## Manual review still needed
- Image registry access on Mac for OpenHands/STT/TTS.
- TLS trust for `config/tls/dev.crt` on macOS Keychain.
- Final port conflict checks on Mac (`80/443/3000/5432/6379/6333`).

## First tests on Mac
1. `./bin/first-run-mac`
2. `cp .env.mac.example .env.mac`
3. `./bin/hosts-entries` and add to `/etc/hosts`
4. `./bin/llm-up-mac`
5. `./bin/llm-check-core`
6. Verify Forgejo URL:
   - `https://forgejo.llmstack.lan/`
   - SSH on `localhost:2222`
