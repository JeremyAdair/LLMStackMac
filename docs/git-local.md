# Forgejo

Forgejo is the local Git service in the `llm-admin` layer.

## Start it

```bash
./tools/bin/cli-handler/llm up admin forgejo
```

## Access

- web: `https://forgejo.llmstack.lan/`
- ssh: `ssh://git@forgejo.llmstack.lan:2222/<owner>/<repo>.git`

SSH port `2222` binds to loopback by default through `HOST_BIND_IP`.

## Auth model

- browser auth goes through Authelia
- Forgejo local login pages are redirected away
- reverse proxy auth headers are used for shared sign-in

## Data

- persistent volume: `forgejo_data`

## Push helper

The repo includes a local push helper with basic secret scanning:

- `tools/bin/git-push/git-push`

That helper is for committed history only; it does not replace review.
