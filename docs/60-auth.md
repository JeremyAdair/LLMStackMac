# Authentication

Authelia is the browser-facing authentication layer for the stack.

## What it protects

- landing page at `https://llmstack.lan/`
- Forgejo
- pgAdmin
- RedisInsight
- Grafana
- Node-RED
- OpenHands
- OpenClaw
- `/console/`
- PDF upload routes on the landing domain

## What it does not protect

- Docker-internal service-to-service traffic
- Postgres, Redis, or Qdrant internal ports
- native Ollama API used by internal stack services

That last point is important: native Ollama is a trusted internal backend, not an Authelia-fronted API.

## Open WebUI auth shape

Open WebUI is configured for OIDC/SSO with Authelia. It is not protected by `auth_request` in the same way as every other route because its API and websocket behavior is handled differently.

## Forgejo auth shape

Forgejo is configured for reverse-proxy authentication:

- local sign-in routes are redirected away
- Authelia is the intended login path
- Nginx forwards the authenticated user header

## User management

Local users live in:

- `config/auth/users_database.yml`

Generate a password hash with:

```bash
docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'change-me'
```

Then restart core services if needed:

```bash
./tools/bin/cli-handler/llm up core
```
