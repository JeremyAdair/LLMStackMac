# tailscale-access

Small host-side helpers for exposing the stack only to Tailscale peers without
having to paste long shell commands into Terminal.

## Scripts

- `enable`
  - installs/updates a narrow `pf` anchor
  - changes `HOST_BIND_IP` and `DNS_BIND_IP` in `.env.mac` to `0.0.0.0`
  - recreates `reverse-proxy`, `dns-server`, and `forgejo`
  - prints the hosts block your other Tailscale PCs should use
- `disable`
  - clears the `pf` anchor
  - restores `HOST_BIND_IP=127.0.0.1` and `DNS_BIND_IP=127.0.0.1`
  - recreates `reverse-proxy`, `dns-server`, and `forgejo`
- `hosts`
  - prints the `.lan` hosts block using this Mac's Tailscale IP
- `status`
  - shows current bind setting, listeners, and loaded `pf` anchor rules

## Finder launchers

Double-clickable macOS launchers are included:

- `Enable Tailscale Access.command`
- `Disable Tailscale Access.command`
- `Tailscale Hosts Block.command`
- `Tailscale Access Status.command`

## Usage

Run from the repo:

```bash
./tools/bin/tailscale-access/enable
./tools/bin/tailscale-access/status
./tools/bin/tailscale-access/hosts
./tools/bin/tailscale-access/disable
```

`enable`, `disable`, and `status` use `sudo` because they inspect or change the
host firewall.
