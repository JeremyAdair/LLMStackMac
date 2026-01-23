# Authentication Gateway

This stack uses Authelia as a self-hosted authentication gateway. It sits in front of protected web services and requires a username and password before access.

## What it does

- Protects web routes at the reverse proxy level.
- Requires login before accessing Open WebUI, Flowise, OpenHands, and Grafana.
- Stores its own user database (file-based for now).

## What it does not do

- It does not secure internal APIs or databases that are not exposed publicly.
- It does not replace application-level roles; it only gates access at the proxy.

## Login flow

1) Browser requests a protected URL.
2) Nginx forwards the request to Authelia for verification.
3) If not logged in, Authelia redirects to its login page.
4) After login, the request is allowed and forwarded to the app.

## Protected routes

- `/` (Open WebUI)
- `/flowise/`
- `/openhands/`
- `/grafana/`
- `/nodered/`

Internal services (Qdrant, Redis, Postgres, STT, TTS, OCR, RAG pipeline) are not exposed publicly and are not protected by the gateway.

## First-time setup

1) Copy the environment example and set auth secrets:

```bash
cp .env.example .env
```

Set these values to strong random strings:

- `AUTHELIA_JWT_SECRET`
- `AUTHELIA_SESSION_SECRET`
- `AUTHELIA_STORAGE_ENCRYPTION_KEY`

2) Create a user hash and update the user database.

Generate a password hash:

```bash
docker run --rm authelia/authelia:latest authelia hash-password --password "change-me"
```

Replace the password hash in `config/auth/users_database.yml` for the `admin` user.

3) Start the stack.

```bash
./bin/llm-up
```

## Add or remove users

Users are stored in `config/auth/users_database.yml`.

- Add a new user entry with a unique name and hashed password.
- Remove users by deleting their block.

After editing, restart Authelia:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/auth/docker-compose.yml \
  restart auth
```

## Rotate passwords

1) Generate a new hash with the same command as above.
2) Update the user entry.
3) Restart Authelia.

## Temporarily disable auth

For debugging only, you can remove the auth checks in the reverse proxy:

1) Edit `config/reverse-proxy/nginx.conf` and comment out the `auth_request` and `error_page` lines.
2) Restart the reverse proxy:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/reverse-proxy/docker-compose.yml \
  restart reverse-proxy
```

## Common failure modes

- Redirect loops: `AUTHELIA_DOMAIN` does not match the host you are using in the browser.
- Login page but no access: missing or incorrect user hash in `users_database.yml`.
- 500 errors at login: missing or empty auth secrets in `.env`.
- Grafana renders incorrectly: `GRAFANA_ROOT_URL` is not set to the `/grafana/` subpath.
