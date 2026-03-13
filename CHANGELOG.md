# Changelog

## Unreleased
- Refactor stack into layered multi-project Compose entrypoints (`llm-core`, `llm-data`, `llm-observability`, `llm-admin`, `llm-lab`) for cleaner Docker Desktop grouping.
- Reorganize `compose/` service modules by layer (`core/`, `data/`, `observability/`, `admin/`, `lab/`) and update script/doc references.
- Add grouped CLI script workflow under `tools/scripts/` (`up/`, `down/`, `status/`, `logs/`, `models/`, `system/`) behind the `llm` router.
- Preserve existing persistent volume identities across projects via explicit external volume names.
- Merge duplicate lab `python-api` + `python-toolbox` runtime into one toolbox service with `python-api` network alias compatibility.
- Fix reverse-proxy DNS startup behavior across layered projects and restore landing static asset routing (buttons/theme/background).
- Move Authelia storage from local SQLite to Postgres-backed storage.
- Reorganize setup-only scripts into `bin/temp-scripts/` to reduce root `bin/` clutter.
- Replace legacy `bin/models-pull` + `models/models.yml` flow with `bin/llm-models-pull`.
- Update docs/runbooks to match model pull and auth storage changes.
- Add and organize security/system prompt assets under `docs/prompts/`.

## 2026-03-09
- `2026-03-09 14:15:52 -0500` `a868cf5` Manage host Ollama in llm-up/down and add security stack prompt.
- `2026-03-09 02:37:13 -0500` `5c01883` Add OpenClaw service with SSO routing and landing integration; fix gateway token bootstrap.

## 2026-03-08
- `2026-03-08 21:38:50 -0500` `3e2c68a` Polish landing layers/UI and finalize monitoring/auth background updates.
- `2026-03-08 19:25:57 -0500` `8dd8454` Cleanup temp artifacts and standardize prompt location.
- `2026-03-08 19:18:34 -0500` `5e79b59` Expand Postgres architecture and migration documentation.
- `2026-03-08 19:01:56 -0500` `dcdc7fa` Add phased Postgres migrations and migration runner.
- `2026-03-08 18:42:54 -0500` `e93f4b2` Restore executable permissions for bin scripts.
- `2026-03-08 18:42:47 -0500` `ef7ecf3` Stabilize pgAdmin SSO auth and expand stack documentation comments.
- `2026-03-08 18:13:05 -0500` `1366256` Harden auth, proxy, and database defaults.
- `2026-03-08 17:50:54 -0500` `cb4d75c` Fix landing links, add pgAdmin/Prometheus routing, and stabilize pgAdmin SSO.
- `2026-03-08 17:29:17 -0500` `964d42d` Remove unused intermediate icon assets.
- `2026-03-08 17:17:31 -0500` `70e85fb` Stabilize Forgejo SSO routing and automate shared-team access sync.
- `2026-03-08 16:27:57 -0500` `fd0bb94` Add mac desktop launchers and fix OpenWebUI banner/header overlap.
- `2026-03-08 07:40:38 -0500` `c4189c0` adjust top banner offset to avoid openwebui overlap.
- `2026-03-08 07:31:24 -0500` `24590e4` harden openwebui to sso-only and fix api auth timeouts.
- `2026-03-08 07:05:18 -0500` `1a9a9ed` auth: enable OpenWebUI SSO via Authelia OIDC.
- `2026-03-08 05:56:47 -0500` `0c1f3dc` docs: finish mac-only cleanup and remove Windows references.
- `2026-03-08 05:50:44 -0500` `d6b9f73` security: stop tracking authelia users database and add local template.
- `2026-03-08 05:48:00 -0500` `5cb5926` Convert stack to mac-only startup and storage defaults.
- `2026-03-08 05:37:30 -0500` `6ed1be5` Unify startup scripts on llm-up and remove llm-up-mac.
