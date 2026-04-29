---
name: investigate
description: Investigate a problem by gathering evidence, inspecting the repo or environment, and identifying the likely culprit before planning. Use when the issue is unclear, symptoms are messy, a crash or failure needs diagnosis, or the user asks to investigate, look into, debug, or triage something.
---

# Skill: investigate

Investigate first. This is Phase 0 of the workflow: gather evidence, inspect the repo or environment, reproduce or confirm the issue if possible, narrow the scope, and identify the likely culprit before planning or implementation. Adapt to the context: use adb/logcat/Gradle for Android, logs and config for CI/CD, tests and stack traces for code issues, and docs/files/process artifacts for non-code problems.

- Prefer evidence over guesses.
- If the repo or system can answer a question, inspect it instead of asking.
- Separate **facts**, **hypotheses**, and **unknowns**.
- If reproduction is expensive or impossible, say so clearly and work from available evidence.
- Do not create `PLAN.md` or start implementation from this skill.
- Recommend `/frame-problem` once the issue is clear enough for `Problem.md`.

End with a compact summary:
- **Observed facts**
- **Likely culprit**
- **Confidence**: low / medium / high
- **Evidence used**
- **Open questions**
- **Recommended next step**

Read references only as needed:
- `references/investigation-patterns.md`
- `references/evidence-checklist.md`
