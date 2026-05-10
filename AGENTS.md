pi.dev agent rules

- **Security**: Do not read, display, or exfiltrate secrets or credentials (e.g. ~/.pi-secrets/, .secrets/, .env*, *.pem, id_rsa, auth.json).
- **Architecture & Patterns**: Before implementing, always analyze the existing codebase for:
    - Established testing frameworks and libraries. Do not introduce new dependencies if the project already has an established way of testing.
    - Coding patterns and folder structure. Strictly adhere to the current architecture and naming conventions.
    - Repo-local extensions live in `pi/extensions/`; keep them as simple TS files when possible and align provider/model names with the public API they wrap.
    - Manual-only extensions should be documented clearly and not added to `scripts/setup.sh` defaults.
- **Workflow Refactor (May 2026)**: We are moving to a "Lean RPIV" workflow. 
    - **Rule**: NEVER implement during a planning phase. The agent failed this twice (May 2026). This is a critical violation of user trust. No script creation, no folder creation, no chmod until the user says "EXECUTE".
    - **Self-Correction**: If the user is asking questions or contemplating, do NOT emit tool calls that modify the filesystem beyond reading.
    - **Triage First**: Always start with `/triage [namespace]:[id]` when working a tracked task.
    - **Namespacing**: Task folders must be in `.workflow/tasks/` using `github-`, `gitlab-`, `jira-`, or `local-`; keep `.workflow/` git-ignored.
    - **Single Task Artifact**: Use `.workflow/tasks/[source-id]/WORK.md` as the task source of truth with guarded sections; avoid reviving `PROBLEM.md` / `PLAN.md` scratch files unless explicitly requested.
    - **Anti-Bloat**: Use `docs/agents/` for condensed long-term context; use `/update-docs` to curate durable docs instead of dumping session history.
    - **Sync**: Use `/sync` for tracker-agnostic Jira/GitHub/GitLab/local updates.
    - **Skill Authoring**: When creating or improving pi skills, use the `pi-skill-creator` process first; do not hand-roll new skills without reading its `SKILL.md` and local skill patterns.
- **Platform Tools**: Use `gh` when the repo remote is GitHub and `glab` when the repo remote is GitLab.
- **Cleanliness**: Never commit scratchpad files used for planning or debugging (e.g., `PLAN.md`, `PROBLEM.md`, `scratch.*`).
- **Commits**: Use Conventional Commits for all commits.

See the repo root AGENTS.md for setup and detailed guidelines.
