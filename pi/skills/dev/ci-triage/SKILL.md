---
name: ci-triage
description: Triage failed CI pipelines, GitHub Actions runs, GitLab pipelines, and local quality gates to identify root cause and the smallest safe fix. Use when a build, test, lint, deploy, PR check, MR pipeline, or workflow job fails.
---

# CI Triage

Find why automation failed and propose the smallest safe next step. This skill is platform-neutral: GitHub Actions, GitLab CI/CD, or local scripts are all just CI signals.

## Hard rules

- Read logs selectively; do not paste huge logs into durable docs.
- Never print secrets. Redact tokens, env values, auth headers, private keys, and credentials.
- Distinguish root cause from downstream failures.
- Prefer a minimal fix over broad refactors.
- Do not rerun expensive or deployment jobs unless the user asks or the repo process requires it.

## Platform commands

Use the platform available for the repo/request:

- GitHub: `gh run list`, `gh run view`, `gh pr checks`, `gh run rerun` only when appropriate.
- GitLab: `glab ci list`, `glab ci view`, `glab mr view`, `glab pipeline ci view` when available.
- Local: inspect `package.json`, Makefiles, Gradle files, CI YAML, and documented verification commands.

If platform CLIs are unavailable, explain the missing tool and use local files/log excerpts provided by the user.

## Workflow

1. Identify failing system: provider, pipeline/run ID, branch, commit SHA, job name, and time.
2. Fetch only relevant failure logs or use user-provided excerpts.
3. Classify failure:
   - code/test failure
   - dependency/install/cache failure
   - config/YAML failure
   - credentials/permissions failure
   - flaky or infrastructure failure
   - timeout/resource limit
   - deployment/environment failure
4. Locate first meaningful error. Ignore cascading noise unless it reveals a separate issue.
5. Map error to changed files, recent commits, or config drift.
6. Recommend one of:
   - fix code/config
   - rerun because likely flaky/infrastructure
   - restore cache/dependency state
   - ask human/admin for credentials or permissions
   - gather one more specific log/artifact
7. If implementing a fix, require explicit implementation approval and follow repo workflow rules.

## Output contract

Return:

- **Failure summary**: provider, job, branch/SHA, first failing signal
- **Likely root cause**: concise and evidence-backed
- **Classification**: one category from the workflow
- **Smallest next action**: fix/rerun/investigate/escalate
- **Evidence**: short log snippets or file references, redacted
- **Commands used**: or commands the user should run
