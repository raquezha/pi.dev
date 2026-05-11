---
name: implement
description: Implement the next approved vertical slice from the active WORK.md and prepare a Draft PR/MR. Use when the plan is approved and the user explicitly asks to implement.
---

# Skill: implement

Execute one functional vertical slice and hand it to the human for review.

## Guardrails
- READ: `.workflow/active_task.json` then active `WORK.md` `[PLAN]`.
- WRITE: code changes and `WORK.md` -> append to `[LOG]` only.
- NEVER: edit `[BRIEF]` or `[GRILL]`.
- NEVER: implement without explicit user instruction.
- NEVER: add `Signed-off-by`; only the human can certify DCO.

## Workflow
1. Identify the first approved unchecked slice in `[PLAN]`.
2. Move tracked task to **In Progress** only when implementation actually starts.
3. **Branch Check**: Verify the current branch matches the task branch in `[META]`. Never work directly on protected branches (`main`, `master`). If a new branch is needed, create it now (e.g., `feat/task-id` or `fix/task-id`).
4. Implement test-first where practical; otherwise document why not in `[LOG]`.
5. Run the slice verification command and available quality gates.
6. Commit with Conventional Commit header and `Assisted-by: AGENT_NAME:MODEL_VERSION [tools]` footer.
7. Push and open a Draft PR/MR with `gh` or `glab` when a remote exists.
8. Append summary, commit hash, and PR/MR link to `[LOG]`.

## Output contract
End with:
- **Slice implemented**
- **Verification run**
- **Commit**
- **Draft PR/MR**
- **Human review required**
