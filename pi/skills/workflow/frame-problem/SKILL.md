---
description: Identify and structure project problems, bug reports, or feature requests. Use when the user has a "messy idea," provides rough notes, or explicitly asks to "frame this problem." This is the first step in the R&D Agentic Workflow.
---

# Skill: frame-problem

Frame a messy or vague problem into a structured `PROBLEM.md` file to kick off the agentic workflow.

## Core Process
1. **Context Gathering**: Read `AGENTS.md`, `pi/AGENTS.md`, and `README.md` first, then read the current chat history and any relevant local files mentioned.
2. **Draft Brief**: Present a concise 3-sentence summary of the problem to the user for immediate alignment.
3. **Draft PROBLEM.md**: Use `references/problem-template.md` to create a structured draft.
4. **Quality Audit**: Ensure the draft meets the criteria in `references/quality-bar.md`.
5. **Execution**: Write the file to `.pi/workflow/PROBLEM.md` automatically.
6. **Next Steps**: Explicitly suggest running `/grill-me` or `/ubiquitous-language`.

## Rules
- **No Hallucinations**: If a section (like "Constraints") is unknown, list it under "Open Questions" instead of guessing.
- **File Safety**: Always write to `.pi/workflow/PROBLEM.md` inside the current repo.
- **Git Hygiene**: Ensure `.pi/workflow/` is listed in `.gitignore` if it is not already ignored.
- **Auto-Write**: Do not pause for approval; write `PROBLEM.md` automatically after drafting and quality-checking it.

## Quality Bar
- Must include **Success Criteria** (how we know it's solved).
- Must include **Non-Goals** (what we aren't doing).
- Must identify the **Primary Blocker**.
