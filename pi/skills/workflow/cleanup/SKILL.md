---
name: cleanup
description: Safely remove finished task folders and merged local branches. Use this to declutter your workspace without losing in-progress work.
---

# Skill: cleanup

The garbage collector for RPIV. Safely removes only what is "done."

## Guardrails
- READ: git branch status, `.workflow/tasks/`, and `WORK.md` states.
- NEVER: delete a task folder if the associated local branch still exists and is UNMERGED.
- NEVER: delete a task folder if `WORK.md` state is not `MERGED` or `CLOSED`.
- DO NOT PANIC on uncommitted changes: Use `git stash` to move them aside during cleanup if a checkout is required.

## Workflow
1. **Sync with Remote**:
   - `git remote update origin --prune`
2. **Handle Dirty Working Tree**:
   - If there are uncommitted changes and you need to switch branches to clean up, use `git stash`. Remember to `git stash pop` at the end.
3. **Identify Merged/Deleted Branches**:
   - List local branches merged into `main` (or master).
   - List local branches whose remote counterparts were deleted (from `git remote update origin --prune` output).
4. **Analyze Task Folders**:
   - For each folder in `.workflow/tasks/`:
     - Read `WORK.md`.
     - **Status Check**: Is it `state: MERGED` or `state: CLOSED`?
     - **Branch Check**: If the associated branch is merged or deleted from remote, it's safe.
5. **Auto-Cleanup (No Nagging)**:
   - For items that are **factually merged** (branch merged to main + task state is MERGED/CLOSED), do NOT ask for confirmation. Just delete them and report the result.
   - ONLY ask for confirmation if there is ambiguity (e.g., the branch is gone but the task state isn't MERGED, or vice versa).
6. **Execution**:
   - Switch to `main`/`master` if not already there (stashing if needed).
   - `git branch -d [branch-name]`
   - `rm -rf .workflow/tasks/[id]`
   - If the current task was deleted, clear `.workflow/active_task.json`.
   - `git stash pop` if you stashed.

## Output contract
End with:
- **Current branch**: `main` or `master`
- **Sync status**: Up to date with remote
- **Cleanup Report**:
  - Branches deleted: List
  - Tasks deleted: List
  - Ambiguous items (skipping): List
- **Next step**: Ready for `/triage`
