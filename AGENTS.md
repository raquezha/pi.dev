pi.dev agent rules

- **Security**: Do not read, display, or exfiltrate secrets or credentials (e.g. ~/.pi-secrets/, .secrets/, .env*, *.pem, id_rsa, auth.json).
- **Architecture & Patterns**: Before implementing, always analyze the existing codebase for:
    - Established testing frameworks and libraries. Do not introduce new dependencies if the project already has an established way of testing.
    - Coding patterns and folder structure. Strictly adhere to the current architecture and naming conventions.
    - Repo-local extensions live in `pi/extensions/`; keep them as simple TS files when possible and align provider/model names with the public API they wrap.
    - Manual-only extensions should be documented clearly and not added to `scripts/setup.sh` defaults.
- **Workflow Order**: Skills that touch workflow files or repo process should read `AGENTS.md`, `pi/AGENTS.md`, and `README.md` first, then inspect the relevant skill docs before editing.
- **Platform Tools**: Use `gh` when the repo remote is GitHub and `glab` when the repo remote is GitLab.
- **Cleanliness**: Never commit scratchpad files used for planning or debugging (e.g., `PLAN.md`, `PROBLEM.md`, `scratch.*`).
- **Commits**: Use Conventional Commits for all commits.

See the repo root AGENTS.md for setup and detailed guidelines.
