# Forgejo SSO Sync Daemon

This daemon script keeps Forgejo users in sync with SSO-authenticated users.

## Why it exists

Forgejo is configured for SSO and reverse-proxy auth, but some user/permission records
need periodic synchronization so SSO users are consistently recognized and authorized.

## Script

- `forgejo-sync-developers`

## Behavior

- Checks whether the Forgejo container is running.
- Applies user/team/permission synchronization logic for SSO-backed users.
- Safe to run repeatedly.

## Usage

```bash
./tools/daemon/forgejo-sync-sso-users/forgejo-sync-developers
```

For continuous operation, run it under your preferred scheduler/supervisor.
