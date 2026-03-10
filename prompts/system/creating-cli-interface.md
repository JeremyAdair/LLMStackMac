We need to reorganize the command structure of this repository to create a clean CLI interface.

Current repo root contains:

assets/
compose/
config/
data/
docs/
eval/
prompts/
repos/
services/
tools/

Inside tools we currently have:

tools/
  bin/
    llm-up
    llm-down
    llm-status
    llm-logs
    llm-models-pull
    llm-check-core
    llm-debug-bundle
    llm-doctor
    llm-up-admin
    llm-up-full
    llm-up-lab
    llm-up-observability
    CreateDesktopIcons
    CreateHostEntries
    ocr-run
    pgadmin-sync-sso-users
    stt-transcribe
    tts-speak
  scripts/
    llm-down-all.sh
    llm-down-core.sh
    llm-ps-stack.sh
    llm-stack-lib.sh
    llm-up-admin.sh
    llm-up-core.sh
    llm-up-full.sh
    llm-up-lab.sh
    llm-up-observability.sh
    llm-validate-compose.sh
    pdf_ingest/
    rag_pipeline/

The current design duplicates functionality between bin and scripts and is messy.

We want to convert this into a clean CLI architecture with ONE entry command called:

llm

The goals:

1. Only ONE CLI command should exist in tools/bin:
   tools/bin/llm

2. Remove the separate executables like:
   llm-up
   llm-down
   llm-status
   llm-logs
   etc.

3. Instead, create a command router in:

tools/bin/llm

This router should dispatch commands to scripts in tools/scripts.

4. Reorganize tools/scripts into command groups like this:

tools/
  scripts/
    up/
      core.sh
      admin.sh
      full.sh
      lab.sh
      observability.sh

    down/
      core.sh
      all.sh

    status/
      status.sh

    logs/
      logs.sh

    models/
      pull.sh

    system/
      doctor.sh
      validate-compose.sh

    ocr/
      run.sh

    stt/
      transcribe.sh

    tts/
      speak.sh

    ingest/
      pdf.sh

5. Move existing scripts into the appropriate folders and rename them where needed.

Examples:

llm-up-core.sh → scripts/up/core.sh  
llm-up-admin.sh → scripts/up/admin.sh  
llm-down-core.sh → scripts/down/core.sh  
llm-down-all.sh → scripts/down/all.sh  
llm-validate-compose.sh → scripts/system/validate-compose.sh  

6. Convert the CLI entrypoint tools/bin/llm into a router script that supports commands like:

llm up core  
llm up admin  
llm up full  
llm down core  
llm down all  
llm status  
llm logs  
llm models pull  
llm doctor  

7. The router should dynamically call scripts from tools/scripts using the command/subcommand pattern.

Example behavior:

llm up core → tools/scripts/up/core.sh  
llm down all → tools/scripts/down/all.sh  
llm models pull → tools/scripts/models/pull.sh  

8. The CLI should support:

llm --help

and print a short usage summary.

9. Ensure all scripts remain executable and keep existing functionality intact.

10. Do NOT change the top level repo structure (assets, compose, config, data, services, etc.). Only reorganize the tools folder and command scripts.

11. After refactoring, the tools directory should look like:

tools/
  bin/
    llm
    CreateDesktopIcons
    CreateHostEntries

  scripts/
    up/
    down/
    status/
    logs/
    models/
    system/
    ingest/
    ocr/
    stt/
    tts/

12. Ensure the llm command works when called like:

llm up core
llm down core
llm status
llm logs
llm models pull

13. Preserve compatibility with Docker Compose commands currently used in the scripts.

14. Ensure the CLI script uses bash and resolves paths relative to the repository root.

Goal:
Convert the repo into a clean CLI-driven architecture so the entire stack can be controlled with the `llm` command.
