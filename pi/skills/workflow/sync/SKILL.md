---
name: sync
description: Sync active WORK.md status to the configured tracker. Use after /plan to publish implementation slices, and after /verify to report verified progress to Jira, GitHub, GitLab, or local logs.
---

# Skill: sync

Bridge the local RPIV workspace and the external tracker without duplicating workflow skills per platform.

## Guardrails
- READ: `.workflow/active_task.json` and active `WORK.md` `[PLAN]` and `[LOG]`.
- WRITE: remote tracker comments/subtasks/status, or append local sync note to `[LOG]` for `local` tasks.
- NEVER: modify `[BRIEF]` or `[GRILL]`.
- NEVER: close tickets automatically; leave final closure to the human.
- NEVER: sync secrets, private tokens, or raw hidden context.

## Workflow
1. Detect source from `.workflow/active_task.json`:
   - `jira` -> use `jira` CLI.
   - `github` -> use `gh` CLI.
   - `gitlab` -> use `glab` CLI.
   - `local` -> no remote; append a local sync note.
2. After `/plan`: publish planned vertical slices as subtasks, task lists, or a tracker comment.
3. After `/verify`: publish verification result, commit hash, and PR/MR link if available.
4. Use tracker-specific status names only when configured or confirmed.
5. Report what was synced and what still needs human action.

## Output contract
End with:
- **Tracker**: jira/github/gitlab/local
- **Synced**: comments/subtasks/status/local log
- **Human action needed**
- **Next step**
