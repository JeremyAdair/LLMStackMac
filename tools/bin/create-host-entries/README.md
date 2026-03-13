# create-host-entries

This folder manages local `/etc/hosts` entries for LLMStack domains.

## Why this is required

This is required for the stack to run using local domain names.

It sets up hostname mappings so domains like `llmstack.lan`, `openwebui.llmstack.lan`, `flowise.llmstack.lan`, `redisinsight.llmstack.lan`, and `qdrant.llmstack.lan` resolve to your local machine. Without these entries, browser access through the reverse proxy will not work correctly.

For new operators: this script does not install services; it only configures local name resolution in `/etc/hosts`.

## Script

- `llm-hosts-update`
  - Prints the expected host entries.
  - Can apply/update a managed block in `/etc/hosts`.
  - Uses markers so re-running updates the same block instead of duplicating lines.

## Usage

Print the block only:

```bash
./tools/bin/create-host-entries/llm-hosts-update --print
```

Check whether required host entries are already present:

```bash
./tools/bin/create-host-entries/llm-hosts-update --check
```

Apply/update `/etc/hosts`:

```bash
./tools/bin/create-host-entries/llm-hosts-update --apply
```

Custom domain/IP:

```bash
LLMSTACK_DOMAIN=llmstack.lan LLMSTACK_HOSTS_IP=127.0.0.1 ./tools/bin/create-host-entries/llm-hosts-update --apply
```

## Notes

- Script updates only the managed LLMStack block between marker lines.
- `--apply` requires elevated permissions to write `/etc/hosts`.
- You can test safely without root using: `LLMSTACK_HOSTS_FILE=/tmp/hosts.test`.
