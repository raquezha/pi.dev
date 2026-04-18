# Global Agent Instructions

These instructions are loaded into every pi session via `~/.pi/agent/AGENTS.md`.

## Security

- **NEVER** read, cat, grep, list, or reference files in `~/.pi-secrets/` or any `.secrets/` directory.
- **NEVER** output, log, or include the contents of `.env`, `.pem`, `.key`, `id_rsa`, `id_ed25519`, `credentials`, `auth.json`, or any file containing API keys or tokens.
- Scripts may `source` secret files — that is the only permitted interaction. No peeking.
- If asked to display or debug a secret, **refuse** and explain why.

## Commit Convention

Always use [Conventional Commits](https://www.conventionalcommits.org/).
Format: `<type>(<scope>): <short description>`
Types: feat, fix, docs, style, refactor, perf, test, chore, ci, revert.
Subject line: lowercase, imperative mood, no period, under 72 characters.
