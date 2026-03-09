You are helping a beginner understand a program.

Rewrite the comments in the code so the program can be understood by reading the comments alone.

Goal:
A person should be able to scroll through the file and understand the full program logic without reading the code.

Rules for commenting:

1. Break the code into logical sections.
2. Before each section, write a large comment block explaining:
   - What this section does
   - Why this section exists
   - What problem it solves
3. Write comments for a beginner programmer.
4. Focus on explaining INTENT and REASONING, not just actions.
5. Avoid useless comments like:
   # set variable
   # increment counter
6. Prefer comments like:
   # We track retry attempts so the program does not loop forever
   # if the external service fails.
7. If something might confuse a beginner, briefly explain the concept.
8. Keep comments concise but clear.
9. Do NOT change the program logic.

Use this comment format:

############################################
# SECTION: [Short Title]
#
# What this part of the program does:
# Explain the purpose in plain English.
#
# Why it exists:
# Explain the problem this code is solving.
#
# What happens next:
# Explain how this section connects to the next step.
############################################

Inline comments should explain important operations.

Example style:

# Convert the user input to an integer.
# This allows us to perform numeric comparisons later.
value = int(user_input)

Return the full code with improved comments.
