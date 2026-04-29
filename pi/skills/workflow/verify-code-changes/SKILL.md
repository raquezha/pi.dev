---
description: Perform a "Never Trust AI" audit of current branch changes. Compares the diff against the Plan/Problem docs, runs quality tools, and removes "AI-isms" before manual human review.
---

# Skill: verify-code-changes

Act as a strict Pre-Reviewer. Your goal is to catch AI mistakes, hallucinations, and lazy coding before the human engineer performs the manual review.

## Core Process
1. **The Diff**: Identify all changes in the current branch compared to the target branch (usually `main`).
2. **Intent Pass**: Verify the changes against `PLAN.md` and `Problem.md`. Ensure all success criteria are met and no "extra" unrelated code was added.
3. **Quality Pass (Adaptive)**: 
   - Run project-specific tools (Lint, Detekt, ktlint, tsc, etc.).
   - If failures occur, attempt auto-fixes (e.g., `ktlintFormat`).
4. **Sanitization Pass**: Use `references/ai-sanitization-checklist.md` to find and remove AI-specific artifacts (placeholders, lazy TODOs, verbose comments).
5. **Domain Pass**: Ensure all new naming aligns with `UBIQUITOUS_LANGUAGE.md` (if available).
6. **Final Report**: Provide a "Verified for Review" summary.

## Rules
- **Be Critical**: Do not assume the code is correct because it "looks" like Kotlin/TS.
- **Auto-Fix Mechanicals**: Formatting and unused imports should be fixed without asking.
- **Flag Logic Gaps**: If the implementation deviates from the plan, flag it clearly.
- **Tidy Up**: Remove any temporary log statements or debug snippets.

## Output Summary Format
- **Status**: [CLEAN] or [ISSUES FIXED/FLAGGED]
- **Alignment**: [Matches PLAN.md / Deviates]
- **Violations Caught**: [List of AI-isms or lint errors fixed]
- **Manual Review Recommended For**: [Specific complex files or logic branches]
