# Workspace container for OpenHands

The workspace container is a safe play area for running OpenHands and CLI tools
against git working copies. It is designed to avoid hidden state and permission
surprises.

## Goals and guardrails

- Only `./workspaces` is writable. The container filesystem is read-only.
- The container runs as a non-root user, using `WORKSPACE_UID` and `WORKSPACE_GID`.
- OpenHands should only operate on paths under `/workspace`.
- Review changes with `git status` and `git diff` before committing.
- Do not push automatically. Push only after review.

## Start the workspace container

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/workspace/docker-compose.yml \
  up -d
```

## Use it safely

1) Clone a repo into `./workspaces` on the host.
2) Connect OpenHands to `/workspace/<repo>`.
3) Run git commands inside the container:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/workspace/docker-compose.yml \
  exec workspace git status
```

If file ownership is incorrect, set `WORKSPACE_UID` and `WORKSPACE_GID` in `.env`
to match your host user and rebuild the workspace image:

```bash
docker compose \
  -f compose/docker-compose.yml \
  -f compose/workspace/docker-compose.yml \
  build --no-cache
```

## Reset and recovery

- `docker compose stop` and `docker compose start` keep both the workspace content
  and the Forgejo volume.
- `docker compose down` keeps named volumes, so Forgejo data remains.
- `docker compose down -v` removes named volumes, including `forgejo_data`.
- The workspace directory is a bind mount. Delete repos under `./workspaces` to
  reset it without affecting the git server.
