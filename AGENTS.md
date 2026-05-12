pi.dev agent guardrails

- **Security**: Do not read, display, or exfiltrate secrets or credentials (e.g. ~/.pi-secrets/, .secrets/, .env*, *.pem, id_rsa, auth.json).

- **Critical implementation rule**: NEVER implement during a planning phase. Do not create files, folders, scripts, or run filesystem-modifying tool calls until the user explicitly says "EXECUTE".

- **Self-correction**: If the user is exploring, asking questions, or planning, do NOT emit tool calls that modify the filesystem beyond reading.

- **Workspace Integrity**: Never create or edit scripts, extensions, or skills directly in the `~/.pi/` workspace. All development must happen within the `pi.dev` repository. Always use `./scripts/setup.sh` to deploy changes to the local machine.

- **Cleanliness**: Never commit scratchpad or ephemeral task files used for planning or debugging (e.g., `PLAN.md`, `PROBLEM.md`, `scratch.*`). Keep ephemeral task state in `.workflow/tasks/`.

- **Commits**: Use Conventional Commits for all commits.

- **Where to find pi-local workflow rules**: See `pi/AGENTS.md` and `docs/agents/workflow.md` for repository-specific workflow, hats, and naming conventions. For guidance on durable documentation edits, see `pi/skills/workflow/update-docs/SKILL.md`.
