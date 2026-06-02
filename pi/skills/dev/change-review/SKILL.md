---
name: change-review
description: Reviews local diffs or GitHub PRs/GitLab MRs for correctness, risk, tests, docs, and review readiness. Use when asked to review a pull request, merge request, branch, patch, or uncommitted change set before approval or handoff.
---

# Change Review

Review a proposed code change regardless of hosting vocabulary: GitHub calls it a PR, GitLab calls it an MR. Use the neutral term **change** in your reasoning and mention PR/MR only when referring to the platform object.

## Hard rules

- Read first; do not modify files unless the user explicitly asks for fixes.
- Never approve blindly. Separate verified facts from assumptions.
- Prefer `gh` for GitHub PRs and `glab` for GitLab MRs.
- Do not read or print secrets (`.env*`, `.secrets/`, credentials, keys, auth files).
- If a change touches agent workflow rules, read `AGENTS.md`, `pi/AGENTS.md`, and relevant `docs/agents/*` before judging.

## Inputs to inspect

Choose the narrowest source that matches the request:

- Local uncommitted change: `git status --short`, `git diff`, and `git diff --staged`.
- Local branch vs base: `git diff --stat <base>...HEAD` and targeted file reads.
- GitHub PR: `gh pr view`, `gh pr diff`, checks if relevant.
- GitLab MR: `glab mr view`, `glab mr diff`, pipeline if relevant.

Also inspect nearby tests, docs, and existing patterns for changed files. Do not introduce a new test framework during review.

## Review workflow

1. Identify scope: files changed, intent, base branch, and platform object if any.
2. Build a risk map:
   - behavior changes
   - compatibility/API changes
   - security/privacy risk
   - data migration or persistence risk
   - test/CI risk
   - docs or agent-instruction drift
3. Read changed files and the closest existing implementation patterns.
4. Check tests and validation commands. If not run, say so.
5. Produce findings by severity:
   - **Blocker**: likely broken, unsafe, or violates hard repo rules.
   - **Major**: should fix before merge.
   - **Minor**: cleanup or maintainability.
   - **Nit**: optional style.
6. If no material findings, say what you checked and remaining risk.

## Output contract

Return:

- **Verdict**: approve / approve-with-nits / request-changes / needs-more-info
- **Scope reviewed**: local diff, branch range, PR, or MR
- **Findings**: severity, file/path, evidence, recommendation
- **Validation**: commands observed/run or not run
- **Residual risk**: unknowns and follow-ups
