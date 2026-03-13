Add a polished CLI banner to the `llm` command.

Requirements:
1. Show a clean ASCII art or text-art banner for:
   - `llm`
   - `llm --help`
2. Do not print the full banner on every subcommand unless in verbose/demo mode.
3. Keep normal commands like `llm up` and `llm down` concise.
4. The help output should look polished and product-like.
5. If appropriate, use subtle ANSI colors for the banner and help text.
6. Keep it readable in a normal terminal.
7. Add a simple usage section below the banner showing commands like:
   - up
   - down
   - status
   - logs
   - doctor
8. Make the banner easy to edit later.

Goal:
Make the `llm` command feel like a real CLI product with a nice branded help screen.
