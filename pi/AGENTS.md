pi.dev agent rules (pi-local)

- **Security**: Do not read, display, or exfiltrate secrets or credentials (e.g. ~/.pi-secrets/, .secrets/, .env*, *.pem, id_rsa, auth.json).

- **Architecture & Patterns**: Before implementing, always analyze the existing codebase for:
  - Established testing frameworks and libraries. Do not introduce new dependencies if the project already has an established way of testing.
  - Coding patterns and folder structure. Strictly adhere to the current architecture and naming conventions.
  - Repo-local extensions live in `pi/extensions/`; keep them as small TS files when possible and align provider/model names with the public API they wrap.
  - Manual-only extensions should be documented and loaded explicitly with `pi -e` when needed.
  - **No Direct `.pi` Edits:** Never create or edit scripts, extensions, or skills directly in the `~/.pi/` workspace. All development must happen in the `pi.dev` repository. Use `./scripts/setup.sh` to deploy changes to the local machine.

- **Lean RPIV workflow (repo-local rules)**:
  - **Triage first**: Start every tracked task with `/triage [namespace]:[id]`. Use explicit namespaces: `jira:`, `github:`, `gitlab:`, `local:`.
  - **Single Task Artifact**: Use `.workflow/tasks/[source-id]/WORK.md` as the canonical task state. Write only to guarded sections (`[BRIEF]`, `[GRILL]`, `[PLAN]`, `[LOG]`, `[META]`).
  - **Namespacing & workspace**: Task folders must live in `.workflow/tasks/` at the repo root (git-ignored). Use folder prefixes like `github-`, `gitlab-`, `jira-`, or `local-` when applicable.
  - **NEVER implement during planning**: Do not create files, folders, scripts, or run filesystem-modifying tool calls until the user explicitly says `EXECUTE`.
  - **Anti-bloat**: Durable context belongs in `docs/agents/`. Use `/update-docs` to curate durable docs; avoid dumping session logs into durable docs.
  - **Sync**: Use `/sync` to bridge the local RPIV workspace with external trackers (GitHub/GitLab/Jira).
  - **Skill authoring**: Use the `pi-skill-creator` process (`pi/skills/meta/pi-skill-creator/SKILL.md`) when creating or improving skills; do not hand-roll new skills without the checklist.
  - **Hats**: The shell integration provides hats (mindsets) such as `--rpiv`, `--android`, `--pm`, `--dev`, `--meta`, `--write`, and `--antigravity` to load appropriate skill sets.
  - **Agent-First Infrastructure**: For any repository, prioritize seeding with `pi agent-os` to ensure standardized context and "Durable Execution" memory.

- **Platform Tools**: Use `gh` for GitHub and `glab` for GitLab.

- **Cleanliness & commits**: Do not commit ephemeral task files. Use Conventional Commits for all changes.

- **References**: `docs/agents/norpiv.md`, `pi/skills/norpiv/update-docs/SKILL.md`, `pi/skills/README.md`.
