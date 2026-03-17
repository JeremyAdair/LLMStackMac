# Operations

## Start and stop

Core:

```bash
./tools/bin/cli-handler/llm up core
```

Observability:

```bash
./tools/bin/cli-handler/llm up observability
./tools/bin/cli-handler/llm up observability-host
```

Admin:

```bash
./tools/bin/cli-handler/llm up admin
```

Lab:

```bash
./tools/bin/cli-handler/llm up lab
```

Everything:

```bash
./tools/bin/cli-handler/llm up full
```

Stop everything:

```bash
./tools/bin/cli-handler/llm down all
```

## Status and diagnostics

```bash
./tools/bin/cli-handler/llm status
./tools/bin/cli-handler/llm doctor
./tools/bin/cli-handler/llm debug-bundle
```

## Tailscale remote access

Enable Tailscale-only web and DNS exposure:

```bash
./tools/bin/remote-access/enable
```

Refresh the Technitium split-DNS zone after the Tailscale IP changes:

```bash
./tools/bin/remote-access/split-dns-sync
```

Run a full repo-history secret scan and import it into DefectDojo:

```bash
./tools/bin/security/defectdojo-gitleaks-scan
```

Check current Tailscale exposure state:

```bash
./tools/bin/remote-access/status
```

The stack-side work is local and reproducible. The one external control-plane
step is setting Tailscale split DNS for `llmstack.lan` to this Mac's Tailscale
IP in the Tailscale admin DNS settings.

## Logs

```bash
./tools/bin/cli-handler/llm logs reverse-proxy auth
SINCE=2h ./tools/bin/cli-handler/llm logs flowise open-webui
```

## Compose layers

Primary files:

- `compose/data.yml`
- `compose/core.yml`
- `compose/observability.yml`
- `compose/observability-host.yml`
- `compose/admin.yml`
- `compose/lab.yml`

## Host Ollama operations

Check models:

```bash
ollama list
```

Re-point host Ollama to an external models path:

```bash
./tools/bin/cli-handler/llm ollama-models-path /Volumes/LLM_DATA/ollama/models
```

Firewall helpers exist, but do not enable them while Docker services still need native Ollama:

```bash
./tools/bin/cli-handler/llm ollama-firewall-status
./tools/bin/cli-handler/llm ollama-firewall-enable
./tools/bin/cli-handler/llm ollama-firewall-disable
```

## Safe defaults to keep

- Keep `HOST_BIND_IP=127.0.0.1` unless you are intentionally exposing the proxy to Tailscale or LAN.
- Keep `docker.sock` consumers opt-in.
- Keep `cadvisor` and `node-exporter` in `observability-host`, not default startup.
