---
name: investigate
description: Investigate a problem by gathering evidence, inspecting the repo or environment, and identifying the likely culprit before planning. Use when the issue is unclear, symptoms are messy, a crash or failure needs diagnosis, or the user asks to investigate, look into, debug, or triage something.
---

# Skill: investigate

Investigate first. Do not jump to implementation or planning until you have enough evidence.

## Purpose
This skill is Phase 0 of the workflow. It helps the agent understand what is actually happening before creating `Problem.md`, `PLAN.md`, or code changes.

## Core process
1. Classify the problem type.
2. Inspect the relevant context and evidence sources.
3. Reproduce or confirm the issue if possible.
4. Narrow the scope and identify likely culprit areas.
5. Capture findings, confidence level, and next step.

## Problem types
Choose the branch that best fits the situation:
- **Android/mobile**: crashes, device issues, adb/logcat, Gradle, runtime errors.
- **CI/CD/infrastructure**: pipeline failures, job config, validation, runner behavior.
- **Codebase/debugging**: failing tests, stack traces, regressions, architecture drift.
- **Non-code/process/docs**: unclear docs, broken workflow, missing decisions, inconsistent terminology.

## Investigation rules
- Prefer evidence over guesses.
- Use the tools that fit the environment.
- If the repo or system can answer a question, inspect it instead of asking the user.
- If reproduction is expensive or impossible, state that clearly and work from available evidence.
- Separate facts, hypotheses, and unknowns.
- Do not create `Problem.md` directly unless the user asks; recommend `/frame-problem` once the issue is understood.
- Do not create `PLAN.md` or start implementation from this skill.

## Output format
At the end, provide a compact investigation summary with:
- **Observed facts**
- **Likely culprit**
- **Confidence**: low / medium / high
- **Evidence used**
- **Open questions**
- **Recommended next step**

## Recommended next steps
- Use `/frame-problem` when the issue is now clear enough to structure into `Problem.md`.
- Use `/grill-me` if the issue is understood but decisions or constraints still need pressure-testing.
- Use `/write-a-plan` only after the problem is clear and approved.

## References
Read these as needed:
- `references/investigation-patterns.md`
- `references/evidence-checklist.md`
- `references/output-template.md`
