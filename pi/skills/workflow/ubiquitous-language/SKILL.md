---
description: Create and maintain a UBIQUITOUS_LANGUAGE.md file to align domain terminology between the user and the agent. Use when starting a new project, noticing naming inconsistencies, or when the user mentions "shared language."
---

# Skill: ubiquitous-language

Build a shared vocabulary to reduce verbosity and ensure the agent uses the same domain terms as the codebase.

## Core Process
1. **Terminology Extraction**: Scan the current codebase (especially directory names, core classes, and `Problem.md`) to identify key domain terms.
2. **Draft Table**: Create/update a Markdown table with the following columns:
   - **Term**: The specific word used in the code/business.
   - **Meaning**: A concise definition (max 1 sentence).
   - **Usage Example**: How to refer to it in chat or code.
3. **Review**: Present the table to the user for refinement. "Are these the correct terms for our domain?"
4. **Execution**: Write to `UBIQUITOUS_LANGUAGE.md` in the project root.
5. **Context Injection**: Advise the user that this file should be fed to the agent in future sessions to keep it "honest" and concise.

## Rules
- **Prefer Code Reality**: If the code uses a specific term (e.g., `Presenter`), do not use a generic term (e.g., `Controller`) even if it's more common globally.
- **Maintain Flat Table**: Keep the table simple and easy for an LLM to parse at a glance.
- **Update Mode**: If `UBIQUITOUS_LANGUAGE.md` already exists, append or refine it rather than overwriting blindly.

## Quality Bar
- No generic AI jargon (e.g., "Leverage", "Robust").
- Terms must be specific to the project's business or technical domain.
- Definitions must be short enough to not bloat the context window.
