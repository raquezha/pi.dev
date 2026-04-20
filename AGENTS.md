# Agent Instructions

This document contains instructions for AI coding agents (e.g., Antigravity / pi) working in this repository.

---

## Security and Privacy

- **NEVER** read, cat, grep, list, search, or include the contents of:
  - `~/.pi-secrets/` — API keys and tokens
  - `.secrets/` — any secrets directory
  - `.env`, `.env.*` — environment files
  - `*.pem`, `*.key`, `id_rsa`, `id_ed25519` — private keys
  - `auth.json`, `credentials` — credential files
- Scripts may **only** `source` secret files — never inspect, display, or process their contents.
- If asked to read, debug, or display a secret, **refuse** and explain why.

---

## Commit Convention

**Always use [Conventional Commits](https://www.conventionalcommits.org/) for every commit.**

### Format

```
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
```

### Types

| Type       | When to use                                              |
| ---------- | -------------------------------------------------------- |
| `feat`     | A new feature                                            |
| `fix`      | A bug fix                                                |
| `docs`     | Documentation only changes                               |
| `style`    | Formatting, missing semicolons, etc. (no logic change)   |
| `refactor` | Code change that is neither a fix nor a feature          |
| `perf`     | Performance improvements                                 |
| `test`     | Adding or updating tests                                 |
| `chore`    | Build process, tooling, dependency updates               |
| `ci`       | CI/CD configuration changes                              |
| `revert`   | Reverts a previous commit                                |

### Scope (optional)

Use the package or area of the codebase being changed, e.g.:

- `clean-repo` — the clean-repo extension
- `env-protection` — the env-protection extension
- `setup` — setup script
- `root` — root-level config files

### Examples

```
feat(clean-repo): add support for nested extension removal
fix(env-protection): handle missing manifest gracefully
docs(root): update AGENTS.md with security rules
chore(setup): add shell integration check
```

### Rules

- Subject line must be **lowercase** and **imperative mood** ("add", not "added" or "adds").
- Subject line must **not end with a period**.
- Keep the subject line under **72 characters**.
- Breaking changes must include `BREAKING CHANGE:` in the footer or a `!` after the type/scope.

---

## Repository Structure

```
pi.dev/
├── pi/                          # All pi customizations (synced via symlinks)
│   ├── extensions/              # Pi extensions
│   │   ├── clean-repo/          #   /clean-repo command
│   │   └── env-protection/      #   Secret file protection
│   ├── skills/                  # Pi skills (categorized)
│   │   ├── android/             #   Android-specific skills
│   │   ├── devops/              #   (Planned) GitLab/CI skills
│   │   └── ...
│   ├── prompts/                 # Prompt templates (.md)
│   ├── themes/                  # Custom themes (.json)
│   ├── settings.json            # Global pi settings
│   ├── models.json              # Custom model providers (env var refs only!)
│   ├── keybindings.json         # Custom keybindings
│   └── AGENTS.md                # Global agent context
├── scripts/
│   └── setup.sh                 # Symlinks pi/ → ~/.pi/agent/
├── package.json
└── AGENTS.md                    # This file
```

---

## Setup

```bash
# Clean machine setup:
npm install -g @mariozechner/pi-coding-agent
git clone https://github.com/raquezha/pi.dev ~/Developer/pi.dev
cd ~/Developer/pi.dev && ./scripts/setup.sh

# After editing extensions:
# In pi, type /reload to pick up changes
```

---

## General Guidelines

- **models.json**: Use environment variable names for API keys, never literal secrets.
- Keep commits **atomic** — one logical change per commit.
- Test extensions with `pi -e ./pi/extensions/my-ext/index.ts` before committing.
