---
name: cleanup
description: Safely prunes local branches and task folders. Reconciles stale Git refs (merged or deleted on remote) and cleans up finished workflow artifacts to maintain general repository hygiene.
---

# Skill: cleanup (Durable Repo Hygiene)

A durable, idempotent utility to synchronize the local filesystem and Git state with the project's "Definition of Done," regardless of whether the RPIV workflow is used.

## Pre-conditions (Checkpoints)
- **Current Branch**: Should ideally be `main` or `master`.
- **Durable State Source**: `git branch` refs and (optionally) `.workflow/tasks/*/WORK.md`.

## Workflow (Durable Steps)

### Step 1: Remote Reconciliation
- `git remote update origin --prune`
- Identify branches deleted on remote.

### Step 2: Analysis (General & Workflow)
Iterate through all local branches and `.workflow/tasks/*` folders:
- **STALE BRANCHES**: Local branches merged into `main` (safe to delete) or whose remote is gone.
- **VERIFIED TASKS**: `.workflow/tasks/*` where `WORK.md` state is `MERGED` or `CLOSED`.
- **ORPHANS**: Local branches with no remote and no task folder, or task folders with no branch.

### Step 3: Atomic Execution
1. **Branch Pruning**: 
   - Use `git branch -d` for merged branches.
   - **Smart Merge Check**: If `-d` fails, check `git log main..[branch]`. If empty, the branch was squash-merged; use `git branch -D` quietly.
2. **Artifact Cleanup**: If a `.workflow/tasks/` folder exists for a pruned branch, `rm -rf` it.
3. **Active Task Reset**: Clear `.workflow/active_task.json` if it points to a deleted task.

### Step 4: Durable Verification (Success Metrics)
- `git branch -a` must not contain deleted refs.
- `.workflow/tasks/` must not contain folders for deleted tasks.

## Guardrails & Recovery
- **Dirty Tree**: If the working tree is dirty, `git stash` before branch switching and `git stash pop` as the final act.
- **Unmerged Work**: If a branch has no remote and contains unique commits, the agent **MUST** ask: "Branch [name] contains unmerged commits and has no remote. Force delete? (y/N)".
- **Idempotency**: If a task folder is missing but the branch remains, delete the branch. If the branch is gone but the folder remains, delete the folder.

## Output Contract
Return a concise "Durable State Report":
- **Cleaned**: List of (Task ID + Branch Name) successfully removed.
- **Skipped/Active**: List of tasks kept and why (e.g., "Contains unmerged commits").
- **Working Branch**: The branch left active (should be `main`).
- **Next step**: Ready for `/triage`.
