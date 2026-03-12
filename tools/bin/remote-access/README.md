# remote-access

Small host-side helpers for exposing the stack only to Tailscale peers without
having to paste long shell commands into Terminal.

## Scripts

- `enable`
  - installs/updates a narrow `pf` anchor
  - changes `HOST_BIND_IP` and `DNS_BIND_IP` in `.env.mac` to `0.0.0.0`
  - recreates `reverse-proxy`, `dns-server`, and `forgejo`
  - syncs the `llmstack.lan` Technitium zone to this Mac's current Tailscale IP
  - prints the nameserver IP and split domain to enter once in the Tailscale admin DNS settings
- `disable`
  - clears the `pf` anchor
  - restores `HOST_BIND_IP=127.0.0.1` and `DNS_BIND_IP=127.0.0.1`
  - recreates `reverse-proxy`, `dns-server`, and `forgejo`
- `split-dns-sync`
  - logs into Technitium through the Docker network
  - creates or updates the `llmstack.lan` zone
  - points every stack hostname at this Mac's current Tailscale IPv4 address
- `hosts`
  - prints a fallback `.lan` hosts block if you are not using Tailscale split DNS yet
- `status`
  - shows current bind setting, listeners, and loaded `pf` anchor rules

## Finder launchers

Double-clickable macOS launchers are included:

- `Enable Tailscale Access.command`
- `Disable Tailscale Access.command`
- `Sync Technitium Split DNS.command`
- `Tailscale Hosts Block.command`
- `Tailscale Access Status.command`

## Usage

Run from the repo:

```bash
./tools/bin/remote-access/enable
./tools/bin/remote-access/split-dns-sync
./tools/bin/remote-access/status
./tools/bin/remote-access/hosts
./tools/bin/remote-access/disable
```

`enable`, `disable`, and `status` use `sudo` because they inspect or change the
host firewall.

After `enable` finishes, add one tailnet-wide DNS entry in Tailscale admin:

- nameserver: this Mac's Tailscale IP
- split domain: `llmstack.lan`
