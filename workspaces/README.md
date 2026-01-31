# Workspace play area

This directory is a local, disposable workspace for running OpenHands and CLI tooling
against git working copies. Only this directory is mounted writable into the workspace
container.

Usage:

1) Clone repositories into `./workspaces`.
2) Run OpenHands against `/workspace/<repo>` paths.
3) Review `git status` and `git diff` before committing.
4) Do not push automatically. Push only after review.

Notes:

- This folder is separate from `./workspace`, which is used for ingestion jobs.
- The workspace container runs as a non-root user. Set `WORKSPACE_UID` and
  `WORKSPACE_GID` in `.env` if you need ownership to match your host user.
- Resetting this directory does not affect the git server volume.
