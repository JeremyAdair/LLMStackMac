# Repo Structure

## Current structure after refactor

```text
LLMStackMac/
  compose/
    core.yml
    data.yml
    observability.yml
    admin.yml
    lab.yml
    <service-module directories retained for compatibility>
  scripts/
    llm-stack-lib.sh
    llm-up-core.sh
    llm-up-observability.sh
    llm-up-admin.sh
    llm-up-lab.sh
    llm-up-full.sh
    llm-down-core.sh
    llm-down-all.sh
    llm-ps-stack.sh
    llm-validate-compose.sh
    <existing utility subdirectories retained>
  bin/
    llm-up
    llm-down
    llm-status
    ...
  config/
  data/
  docs/
  python-toolbox/
  workspace/
```

## Why service-module compose directories were retained

Directories like `compose/auth`, `compose/flowise`, `compose/postgres`, etc. were not deleted in this pass to avoid breaking existing references, runbooks, and rollback workflows.

The new `compose/*.yml` files are now the primary layer entrypoints.

## Conventions going forward

- New long-running services should be added to one layer file first.
- Keep data mounts and env vars stable.
- Put one-off scripts/jobs in `lab` unless they are mandatory for daily operation.
- Keep admin tooling off by default.
