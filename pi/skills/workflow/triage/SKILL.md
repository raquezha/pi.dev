---
name: triage
description: "Ingest a tracked or local task into the RPIV workspace. Use when starting work from jira:, github:, gitlab:, or local: and you need to create or resume a namespaced WORK.md."
---

# Skill: triage

Start RPIV by creating or resuming a task workspace.

## Guardrails
- READ: user argument `[source]:[id]` and existing `.workflow/active_task.json` if resuming.
- WRITE: `.workflow/tasks/[source-id]/WORK.md`, `.workflow/tasks/[source-id]/metadata.json`, `.workflow/active_task.json` only.
- NEVER: create `PROBLEM.md`, `PRD.md`, `PLAN.md`, or `EVIDENCE.md`.
- NEVER: implement code during triage.
- NEVER: guess source from `#123`; require explicit `jira:`, `github:`, `gitlab:`, or `local:`.

## Workflow
1. Parse namespace:
   - `jira:PROJ-123` -> `jira-PROJ-123`
   - `github:42` -> `github-42`
   - `gitlab:42` -> `gitlab-42`
   - `local:name` -> `local-name` (descriptive name preferred over generic IDs)
2. Use `pi/scripts/workflow/triage_helper.sh` to fetch remote data and create/resume `.workflow/tasks/[source-id]/WORK.md`.
   - **Smart Naming**: If the user provides a generic local ID like `PROBLEM` or `work`, the helper script and agent MUST fallback to the current git branch name to ensure a unique, meaningful namespace.
3. Classify the task:
   - **Problem**: bug, regression, crash, broken behavior.
   - **Proposal**: feature, enhancement, refactor, new behavior.
4. Record classification in `[BRIEF]` if missing, or append a short note to `[LOG]` if resuming.
5. **Branch Guardrail**: If the current branch is `main` or `master`, warn the user and recommend creating a feature branch or running `clean-repo` (extension) if the workspace is stale. Record the starting branch in `[META]`.
6. End by recommending `/frame` unless `[BRIEF]` is already complete.

## Output contract
End with:
- **Active task**: `[source-id]`
- **Workspace**: `.workflow/tasks/[source-id]/WORK.md`
- **Classification**: Problem / Proposal / Unknown
- **Next step**: `/frame` or resume appropriate phase
