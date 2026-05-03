---
description: Execute a PLAN.md using Vertical Slices and TDD. Automatically manages GitHub/GitLab PRs/MRs and enforces repository standards and naming conventions.
---

# Skill: implement-plan

Execute a technical plan with precision, ensuring vertical implementation, TDD loops, and platform-aware git management.

## Core Process
1. **Discovery & Alignment**:
   - Detect Platform: Check `git remote -v` for GitHub vs GitLab.
   - Read Standards: Read `UBIQUITOUS_LANGUAGE.md` (if available) to align naming.
   - Read Plan: Parse `PLAN.md` to identify the first/next Vertical Slice.
   - Inspect Branch Context: Read `git branch --show-current`, recent commit messages, and the plan objective to determine whether the current branch matches the work.
2. **Branch Decision**:
   - If the current branch is `main`, `master`, or any protected branch, create a new feature branch before implementing.
   - If the current branch is not protected, compare its name, recent commit message, and plan context to the plan scope.
   - If the branch is unrelated or ambiguous, create a new branch off `main` for the plan.
   - If the branch is clearly aligned with the plan, continue on the current branch.
   - Never assume alignment when the context is unclear.
3. **Environment Setup**:
   - Ensure a dedicated branch exists before implementation.
   - Create a **Draft PR/MR** immediately after confirming the branch is appropriate.
   - **MR Description Rule**: Use the structure defined in `references/mr-template.md`. The content MUST be derived from the `Objective` and `Success Criteria` in the `PROBLEM.md` and `PLAN.md`. It should summarize the functional changes and why they matter, formatted for a human reviewer. Avoid "agent-speak".
4. **The Vertical Slice Loop**:
   - **Phase 0 (TDD)**: Implement the failing test for the current slice. Verify failure.
   - **Phase 1-3 (Build)**: Implement the code from the bottom (foundations) to the top (integration).
   - **Verification**: Run the plan's verification command.
   - **Adaptive Quality Gate**: Before committing, attempt to run project-specific quality tools (e.g., `./gradlew ktlintCheck detekt lint`, `npm run lint`, etc.). If tools are missing or tasks are not found, skip gracefully.
   - **Audit**: Check naming against the project's dictionary and ensure consistency with any CI standards found in local notes.
   - **Commit**: `git commit -m "feat: [slice summary]"` once verified and quality-checked.
5. **Context Refresh**: After each slice, re-read the Plan and update the session context with current progress.

## Rules
- **Vertical Only**: Do not implement horizontal layers (e.g., all models at once). Build functional features.
- **TDD Enforcement**: Never write implementation code before a failing test exists.
- **Atomic History**: One verified vertical slice = one clean commit.
- **Protected Branch Safety**: Never commit, push, or open a PR/MR from a protected branch.
- **Branch Alignment**: Do not assume the current branch is correct; verify branch/commit context against the plan first.
- **File Safety**: Treat `.pi/workflow/PLAN.md` and `.pi/workflow/PROBLEM.md` as repo-local scratch artifacts, not source-of-truth docs.
- **Platform Liaison**: Use `gh` for GitHub and `glab` for GitLab. If neither is available, inform the user and continue with local git.
- **Clean Titles**: When creating a Draft PR/MR, never include "Draft" or "WIP" in the title string; let the CLI flags handle the status to avoid double-prefixing.
- **CI-Safety**: Attempt to fix formatting (e.g., `ktlintFormat`) automatically if the quality gate fails.

## Quality Bar
- Code must pass the project's linter/static analysis.
- Every slice must be independently verifiable.
- All naming must be consistent with the project's existing language.
