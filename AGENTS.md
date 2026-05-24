pi.dev agent guardrails

- **Security**: Do not read, display, or exfiltrate secrets or credentials (e.g. ~/.pi-secrets/, .secrets/, .env*, *.pem, id_rsa, auth.json).

- **Critical implementation rule**: NEVER implement during a planning phase. Do not create files, folders, scripts, or run filesystem-modifying tool calls until the user explicitly says "EXECUTE".

- **Self-correction**: If the user is exploring, asking questions, or planning, do NOT emit tool calls that modify the filesystem beyond reading.

- **Workspace Integrity**: Never create or edit scripts, extensions, or skills directly in the `~/.pi/` workspace. All development must happen within the `pi.dev` repository. Always use `./scripts/setup.sh` to deploy changes to the local machine.

- **Cleanliness**: Never commit scratchpad or ephemeral task files used for planning or debugging (e.g., `PLAN.md`, `PROBLEM.md`, `scratch.*`). Keep ephemeral task state in `.workflow/tasks/`.

- **Commits**: Use Conventional Commits for all commits.

- **Where to find pi-local workflow rules**: See `pi/AGENTS.md` and `docs/agents/workflow.md` for repository-specific workflow, hats, and naming conventions. For guidance on durable documentation edits, see `pi/skills/workflow/update-docs/SKILL.md`.
- **Markdown preview package**: `./scripts/setup.sh` installs/enables `npm:pi-markdown-preview` globally in Pi. It is not tied to a hat and should be available in normal sessions alongside search skills like Brave/Firecrawl.

Active task canonical schema

- The workflow uses a single pointer file at `.workflow/active_task.json` to indicate the repo's current active task. Scripts and skills should rely on a canonical, backward-compatible shape with these fields (preferred order):
  - active_task: the namespaced folder name under `.workflow/tasks`, e.g. "local-search-worker-backend".
  - source: the task source (e.g., "local", "github", "gitlab", "jira").
  - id: the raw remote id (e.g., issue number or short local id). Keep this as-is in metadata.json.
  - sourceId: aliased to id for compatibility with older scripts.
  - taskPath / path: repo-relative path to the task folder (e.g., ".workflow/tasks/local-search-worker-backend"). Prefer this if present.
  - branch: optional branch name (helps branch-enforcement and diagnostics).

- Producer (triage_helper.sh) behavior: continue to create folders as `.workflow/tasks/<source>-<id>` and write metadata.json with the raw id under `id`. In addition, triage now writes the canonical `.workflow/active_task.json` with the fields above and also records `taskFolder` in the task's metadata.json for discoverability.

- Consumer (enforce-branch.sh and other scripts) behavior: prefer `taskPath` when present; if absent, derive the task folder from `source` + `id` (i.e., `<source>-<id>`). Emit clear diagnostics when neither `taskPath` nor `id` are available.

- Validation: A lightweight, print-only validation script is available at `pi/scripts/workflow/validate_active_task.sh` to help inspect and remediate inconsistent state without making automatic changes.

Migration and compatibility

- New enforcement logic is backward-compatible with older active_task.json files that contain `taskPath` or `source`+`id`. A repo migration helper can be added to normalize legacy pointers; for safety, any migration will be print-only by default and require an explicit flag to apply changes.

If you maintain other automation that reads `.workflow/active_task.json`, update those consumers to prefer `taskPath` and to gracefully fall back to `source`+`id` as described above.

