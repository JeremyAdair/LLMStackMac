# Stack Modes

## Daily use (recommended)

```bash
./scripts/llm-up-core.sh
```

Starts:

- `llm-data`
- `llm-core`

## Core + observability

```bash
./scripts/llm-up-core.sh
./scripts/llm-up-observability.sh
```

## Admin session

```bash
./scripts/llm-up-admin.sh
```

## Lab session

```bash
./scripts/llm-up-lab.sh
```

## Full stack

```bash
./scripts/llm-up-full.sh
```

## Stop

```bash
./scripts/llm-down-core.sh
./scripts/llm-down-all.sh
```

## Compatibility commands

`bin` wrappers are kept for muscle memory:

```bash
./bin/llm-up          # full
./bin/llm-up core
./bin/llm-up admin
./bin/llm-up lab
./bin/llm-down        # all
./bin/llm-status
```
