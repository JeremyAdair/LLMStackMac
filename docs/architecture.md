# Layered Docker Architecture

The stack is now split into multiple Docker Compose projects so Docker Desktop shows clean grouped stacks instead of one flat project.

## Projects

- `llm-data`: stateful datastores.
- `llm-core`: daily-use user-facing services.
- `llm-observability`: metrics and monitoring.
- `llm-admin`: operator/admin UIs.
- `llm-lab`: experimental and workflow tooling.

All projects connect to one external shared network:

- `llm-shared`

This keeps cross-project DNS stable (`postgres`, `qdrant`, `flowise`, etc.) while preserving separate project grouping in Docker Desktop.

## Why this model

- Cleaner Docker Desktop UX with collapsible service groups.
- Clear operational boundaries between always-on and optional services.
- Lower default resource footprint.
- Safer maintenance and upgrades by layer.
- No Kubernetes overhead for a macOS homelab.

## Security constraints preserved

- SSO/auth remains in front of protected UIs.
- Persistent data paths/volumes are preserved.
- Admin/lab services are no longer always-on.
- OpenHands no longer mounts `docker.sock` by default.
