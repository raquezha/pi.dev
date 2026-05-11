---
name: clean-repo
description: Reset workspace — checkout main, pull, prune, and delete merged branches. Use this when starting a new task or if your local branch state is stale/cluttered.
---

# Skill: clean-repo

Maintain a clean and up-to-date repository state.

## Guardrails
- READ: git branch and status.
- WRITE: git branch changes and deletions (after confirmation).
- NEVER: delete unmerged branches without explicit confirmation.
- NEVER: force push or modify remote protected branches.

## Workflow
1. Use the `clean-repo` extension command if available, or perform the following steps:
2. Check for uncommitted changes; suggest stashing or committing if they exist.
3. Determine the primary branch (`main` or `master`).
4. Checkout the primary branch and pull the latest changes.
5. Prune stale remote references (`git fetch --prune`).
6. Identify and delete local branches that have been merged into the primary branch.
7. List any unmerged branches that were kept.

## Output contract
End with:
- **Current branch**: `main` or `master`
- **Sync status**: Up to date with remote
- **Branches cleaned**: Count of deleted branches
- **Next step**: Ready for `/triage`
