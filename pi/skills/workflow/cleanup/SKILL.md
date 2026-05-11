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
- NEVER: delete uncommitted changes.

## Workflow
1. **Sync with Remote**:
   - `git remote update origin --prune`
2. **Identify Merged Branches**:
   - List local branches merged into `main` (or master).
   - `git branch --merged main | grep -v '^\*' | grep -v 'main$' | grep -v 'master$'`
3. **Analyze Task Folders**:
   - For each folder in `.workflow/tasks/`:
     - Read `WORK.md`.
     - **Status Check**: Is it `state: MERGED`?
     - **Branch Check**: Does the associated branch (from `[META]` or `metadata.json`) still exist? If yes, has it been merged into main?
4. **Determine "Safe to Delete"**:
   - A task is safe ONLY if:
     1. Its local branch is merged into main OR its branch was deleted from remote.
     2. AND its `WORK.md` state indicates completion.
5. **Human Confirmation**:
   - List the candidates for deletion (Branches and Folders).
   - Ask: "These tasks are finished. Delete them? (y/n)"
6. **Execution**:
   - `git branch -d [branch-name]`
   - `rm -rf .workflow/tasks/[id]`
   - If the current task was deleted, clear `.workflow/active_task.json`.

## Output contract
End with:
- **Branches removed**: List
- **Tasks removed**: List
- **Remaining active tasks**: List
- **Next step**: Ready for new work on `main`.

## Output contract
End with:
- **Current branch**: `main` or `master`
- **Sync status**: Up to date with remote
- **Branches cleaned**: Count of deleted branches
- **Next step**: Ready for `/triage`
