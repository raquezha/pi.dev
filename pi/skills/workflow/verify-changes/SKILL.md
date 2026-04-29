---
description: Perform a holistic integrity check of all project changes (Code, Docs, CI, Static Site). Compares the diff against the Plan/Problem, ensures cross-file truth, and removes "AI-isms" before manual review.
---

# Skill: verify-changes

Verify the total integrity of the project's state. Your goal is to ensure that code, documentation, and infrastructure are in perfect sync and free of AI artifacts.

## Core Process
1. **The Total Diff**: Analyze all changes in the current branch across all file types (Source code, Markdown, YAML, Config).
2. **System-Wide Zoom Out**: Identify dependent modules or distant files that might be affected by these changes. Explain in 2 sentences how this work impacts the broader project architecture and check for unintended side effects.
3. **The "Truth Test"**: 
   - Use `grep` or `find` to discover documentation or config files (README, mkdocs, ZenStack, schemas) relevant to the code changes.
   - Verify that all identified artifacts reflect the new reality of the code. If code says "X" but doc says "Y", it is an integrity failure.
3. **Intent Validation**: Compare the total diff against `PLAN.md` and `PROBLEM.md`. Ensure all success criteria are met across both logic and documentation.
4. **Quality Gate (Adaptive)**: 
   - Run project-specific tools (Lint, Detekt, ktlint, tsc, mkdocs build, etc.).
   - Attempt auto-fixes (e.g., `ktlintFormat`) for mechanical violations.
5. **Sanitization Pass**: Use `references/ai-sanitization-checklist.md` to remove AI-specific noise (placeholders, lazy TODOs, boilerplate comments).
6. **Domain Pass**: Ensure all naming and descriptions align with `UBIQUITOUS_LANGUAGE.md`.

## Rules
- **Agnostic Integrity**: Treat documentation and configuration as "Code." They must be accurate and in sync.
- **Discovery First**: Do not rely on hardcoded paths for docs. Search the repo to "Find the Truth."
- **Auto-Fix Mechanicals**: Formatting, unused imports, and stale doc strings should be fixed immediately.
- **No Agent Speak**: Final reports and MR descriptions must be human-centric and professional.

## Output Summary Format
- **Status**: [CLEAN] or [INTEGRITY ISSUES FIXED/FLAGGED]
- **Truth Sync**: [Verified: Docs/Config match Code / Deviations found]
- **Violations Caught**: [List of AI-isms, doc errors, or lint fixes]
- **Manual Review Recommended For**: [Specific complex artifacts]
