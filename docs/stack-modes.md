# Stack Modes

## Daily use (recommended)

```bash
./tools/scripts/up/core.sh
```

Starts:

- `llm-data`
- `llm-core`

## Core + observability

```bash
./tools/scripts/up/core.sh
./tools/scripts/up/observability.sh
```

## Admin session

```bash
./tools/scripts/up/admin.sh
```

## Lab session

```bash
./tools/scripts/up/lab.sh
```

## Full stack

```bash
./tools/scripts/up/full.sh
```

## Stop

```bash
./tools/scripts/down/core.sh
./tools/scripts/down/all.sh
```

## Compatibility commands

`bin` wrappers are kept for muscle memory:

```bash
./tools/bin/llm up full          # full
./tools/bin/llm up core
./tools/bin/llm up admin
./tools/bin/llm up lab
./tools/bin/llm down all        # all
./tools/bin/llm status
```
