---
name: plan
description: Create or revise vertical implementation slices in the active WORK.md. Use after /grill-with-docs to produce a concise, reviewable plan for implementation.
---

# Skill: plan

Map the "how" into tracer-bullet vertical slices.

## Guardrails
- READ: `.workflow/active_task.json` then active `WORK.md` `[BRIEF]` and `[GRILL]`.
- WRITE: `WORK.md` -> `[PLAN]` and append to `[LOG]` only.
- NEVER: implement code during planning.
- NEVER: create standalone `PLAN.md`.
- NEVER: ask whether to plan if the user invoked `/plan`; produce the plan.

## Workflow
1. Read the brief and grill decisions.
2. **Branch Check**: Verify the current git branch matches the branch recorded in `[META]`. If on `main` or `master`, warn that planning on a protected branch is discouraged unless it's a documentation-only task.
3. Draft thin vertical slices that are independently verifiable.
3. Mark each slice:
   - **AFK**: agent can implement with clear checks.
   - **HITL**: human judgment, product decision, external access, or manual review required.
4. Include dependencies and verification command(s) per slice.
5. Write the plan into `[PLAN]` with checkboxes.
6. **Log Activity**: Append a timestamped entry to `[LOG]` summarizing the plan or revision (e.g., "Plan created" or "Plan updated after pivot").
7. Recommend `/sync` if the task has a tracker, then `/implement`.

## Output contract
End with:
- **Slices**: count and names
- **AFK/HITL split**
- **Verification commands**
- **Next step**: `/sync` or `/implement`
