# Agent Instructions

This document contains instructions for AI coding agents (e.g., Antigravity / pi) working in this repository.

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

- `ext-cleanup` — the `packages/ext-cleanup` package
- `root` — root-level config files

### Examples

```
feat(ext-cleanup): add support for nested extension removal
fix(ext-cleanup): handle missing manifest gracefully
docs(root): add AGENTS.md with commit conventions
chore(root): update eslint config to flat format
```

### Rules

- Subject line must be **lowercase** and **imperative mood** ("add", not "added" or "adds").
- Subject line must **not end with a period**.
- Keep the subject line under **72 characters**.
- Breaking changes must include `BREAKING CHANGE:` in the footer or a `!` after the type/scope, e.g. `feat!: drop Node 18 support`.

---

## Repository Structure

```
pi.dev/
├── packages/
│   └── ext-cleanup/      # Extension cleanup tooling
├── eslint.config.cjs     # ESLint flat config
├── tsconfig.json         # Root TypeScript config
├── package.json          # Root workspace package
└── AGENTS.md             # This file
```

---

## General Guidelines

- Run `npm run lint` before committing to catch lint errors.
- Run `npm run format` to auto-format code before committing.
- Never commit directly to `main` without a meaningful conventional commit message.
- Keep commits **atomic** — one logical change per commit.
