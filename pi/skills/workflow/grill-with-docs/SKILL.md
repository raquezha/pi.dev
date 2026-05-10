---
name: grill-with-docs
description: Stress-test the active WORK.md brief against docs, code, and domain language. Use after /frame before planning to clarify assumptions and update durable docs only when decisions are stable.
---

# Skill: grill-with-docs

Challenge the brief before planning. This replaces passive ubiquitous-language collection with active clarification.

## Guardrails
- READ: `.workflow/active_task.json`, active `WORK.md` `[BRIEF]`, `CONTEXT.md`, and relevant `docs/agents/*`.
- WRITE: `WORK.md` -> append to `[GRILL]` only; durable docs only when a stable rule is confirmed.
- NEVER: edit `[BRIEF]` silently; propose brief changes if contradictions are found.
- NEVER: plan or implement during grilling.
- NEVER: ask questions the codebase can answer; inspect first.

## Workflow
1. Read the active brief and relevant durable context.
2. Cross-check claims against code, docs, ADRs, and platform conventions.
3. Ask one question at a time only when a decision is unresolved.
4. Call out fuzzy or conflicting language.
5. Append resolved decisions, edge cases, and constraints to `[GRILL]`.
6. If a durable term/rule emerges, propose a concise `docs/agents/*` update.

## Output contract
End with:
- **Resolved decisions**
- **Remaining blockers**
- **Docs updates proposed/applied**
- **Next step**: `/plan` only when the brief is stable
