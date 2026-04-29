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
2. **Environment Setup**:
   - Ensure a dedicated branch exists (create from `PLAN.md` suggestion if needed).
   - Create a **Draft PR/MR** immediately to establish the remote feedback loop.
3. **The Vertical Slice Loop**:
   - **Phase 0 (TDD)**: Implement the failing test for the current slice. Verify failure.
   - **Phase 1-3 (Build)**: Implement the code from the bottom (foundations) to the top (integration).
   - **Verification**: Run the plan's verification command.
   - **Adaptive Quality Gate**: Before committing, attempt to run project-specific quality tools (e.g., `./gradlew ktlintCheck detekt lint`, `npm run lint`, etc.). If tools are missing or tasks are not found, skip gracefully.
   - **Audit**: Check naming against the project's dictionary and ensure consistency with any CI standards found in local notes.
   - **Commit**: `git commit -m "feat: [slice summary]"` once verified and quality-checked.
4. **Context Refresh**: After each slice, re-read the Plan and update the session context with current progress.

## Rules
- **Vertical Only**: Do not implement horizontal layers (e.g., all models at once). Build functional features.
- **TDD Enforcement**: Never write implementation code before a failing test exists.
- **Atomic History**: One verified vertical slice = one clean commit.
- **Platform Liaison**: Use `gh` for GitHub and `glab` for GitLab. If neither is available, inform the user and continue with local git.
- **Clean Titles**: When creating a Draft PR/MR, never include "Draft" or "WIP" in the title string; let the CLI flags handle the status to avoid double-prefixing.
- **CI-Safety**: Attempt to fix formatting (e.g., `ktlintFormat`) automatically if the quality gate fails.

## Quality Bar
- Code must pass the project's linter/static analysis.
- Every slice must be independently verifiable.
- All naming must be consistent with the project's existing language.
