# Agent Workflow Context

Durable workflow context for pi.dev. Keep this concise and update via `/update-docs` when workflow rules change.

Overview
- Lean RPIV: Triage → Frame → Grill → Plan → Implement → Verify. Each phase maps to a workflow skill under `pi/skills/workflow/`.

Core phases
- Triage (`/triage`): Fetch remote issue data and create or resume a namespaced workspace at `.workflow/tasks/[source-id]/`. Initialize `metadata.json` and `WORK.md` if needed.
- Frame (`/frame`): Author a concise brief in the active `WORK.md` `[BRIEF]` section. Do NOT create separate `PROBLEM.md` or `PRD.md` files.
- Grill (`/grill-with-docs`): Validate the brief against `CONTEXT.md`, `docs/agents/*`, and codebase rules. Record decisions in `[GRILL]`.
- Plan (`/plan`): Produce thin, verifiable vertical slices in `[PLAN]`. Mark slices AFK/HITL and include verification commands.
- Implement (`/implement`): Execute one approved slice, commit with Conventional Commit headers, push, and open a Draft PR/MR. Append results to `[LOG]`.
- Verify (`/verify`): Run verification commands and quality gates. Append verification evidence to `[LOG]` and recommend `/sync` if needed.

Workspace & namespacing
- Task workspace: `.workflow/tasks/[source-id]/` (repo root). Use guarded sections inside `WORK.md`: `[BRIEF]`, `[GRILL]`, `[PLAN]`, `[LOG]`, `[META]`.
- Namespacing: Prefer explicit source prefixes: `jira:`, `github:`, `gitlab:`, `local:`. Use `github-`, `gitlab-`, `jira-`, or `local-` folder prefixes when creating local task folders.
- Keep `.workflow/` git-ignored and do not persist temporary task state to durable docs.

Hats (mindsets)
- Use the shell integration flags to load specific mindsets and skill sets: `--rpiv`, `--android`, `--pm`, `--dev`, `--meta`, `--write`, `--antigravity`.

Anti-bloat checklist (before editing durable docs)
1. Is this a durable rule or a session event?
2. Will a future agent need this on similar tasks?
3. Is this already documented elsewhere?
4. Can this be one clear rule instead of long narrative?
5. Does this belong in a skill reference instead of `docs/agents/`?

Where to edit durable docs
- Use `/update-docs` (`pi/skills/workflow/update-docs/SKILL.md`). Prefer rules and decisions; avoid full session transcripts.

References
- `pi/skills/workflow/update-docs/SKILL.md`
- `pi/skills/README.md`
