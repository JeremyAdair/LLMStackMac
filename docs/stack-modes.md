# Stack Modes

## Recommended daily mode

```bash
./tools/bin/cli-handler/llm up core
```

Starts:

- `llm-data`
- `llm-core`

## Observability

```bash
./tools/bin/cli-handler/llm up observability
```

Add host-level exporters only when you intentionally want the extra trust:

```bash
./tools/bin/cli-handler/llm up observability-host
```

## Admin

```bash
./tools/bin/cli-handler/llm up admin
```

## Lab

```bash
./tools/bin/cli-handler/llm up lab
```

Default `up lab` starts:

- `python-toolbox`
- `node-red`
- `console`
- `openclaw`
- `openhands`
- `rag-pipeline`
- `pdf-ingest`
- `ocr`

## Full stack

```bash
./tools/bin/cli-handler/llm up full
```

## Stop

```bash
./tools/bin/cli-handler/llm down all
```
