# Auto CLI Discovery Refactor Prompt

We want to upgrade the CLI architecture of this repository to support automatic command discovery.

Goal:
The `llm` CLI should automatically discover commands based on the folder structure in `tools/scripts` instead of using a hardcoded router with many case statements.

The command pattern should work like this:

`llm <command> <subcommand> [args...]`

Examples:

- `llm up core`
- `llm up admin`
- `llm up full`
- `llm down core`
- `llm down all`
- `llm status`
- `llm logs`
- `llm models pull`
- `llm doctor`
- `llm ingest pdf`
- `llm ocr run`
- `llm stt transcribe`
- `llm tts speak`

Repository structure (current target):

```text
tools/
  bin/
    llm

  scripts/
    up/
      core.sh
      admin.sh
      observability.sh
      lab.sh
      full.sh

    down/
      core.sh
      all.sh

    status/
      show.sh

    logs/
      show.sh

    models/
      pull.sh

    system/
      doctor.sh
      check-core.sh
      debug-bundle.sh
      validate-compose.sh

    ingest/
      pdf.sh

    ocr/
      run.sh

    stt/
      transcribe.sh

    tts/
      speak.sh
```

Requirements:

1. Replace the current CLI router in `tools/bin/llm` with an auto-discovery router.

2. The router should:

- detect command and subcommand arguments
- map them to a script path inside `tools/scripts`
- execute the script if it exists

Example mapping:

- `llm up core` -> `tools/scripts/up/core.sh`
- `llm down all` -> `tools/scripts/down/all.sh`
- `llm models pull` -> `tools/scripts/models/pull.sh`
- `llm ingest pdf` -> `tools/scripts/ingest/pdf.sh`

3. If a command has only one level (like `llm status` or `llm logs`) the router should fallback to:

`tools/scripts/<command>/show.sh`

Example:

- `llm status` -> `tools/scripts/status/show.sh`
- `llm logs` -> `tools/scripts/logs/show.sh`

4. If the script exists and is executable, run it and pass any remaining arguments.

5. If no matching script exists, print a helpful error message and show available commands.

6. Add support for:

- `llm --help`
- `llm help`

The help output should:

- show the ASCII banner
- list commands
- optionally auto-scan `tools/scripts` to list commands dynamically

7. Ensure all scripts in `tools/scripts` are executable.

8. Resolve paths relative to the repo root so the CLI works from any directory.

9. Do not change the overall repository structure outside of `tools/bin` and `tools/scripts`.

10. Maintain compatibility with existing Docker Compose commands and service scripts.

11. After implementation, validate that these commands work:

- `llm up core`
- `llm up full`
- `llm down core`
- `llm down all`
- `llm status`
- `llm logs`
- `llm models pull`
- `llm doctor`
- `llm ingest pdf`
- `llm ocr run`
- `llm stt transcribe`
- `llm tts speak`

12. Provide a summary of:

- new router implementation
- scripts discovered
- any scripts renamed or moved
- validation results

Design principle:

The CLI should scale without modifying the router.

Adding a new command should only require adding a new script file in:

`tools/scripts/<command>/<subcommand>.sh`
