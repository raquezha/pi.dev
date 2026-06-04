# Agentic Terminology Guide

Concise definitions and best practices for LLM-related metrics and agentic terms used across this repository. Keep this page durable and minimal; use `/update-docs` to evolve it.

## LLM metrics

- Context
  - What: The set of information provided to the model at request time (prompt, system instructions, in-file snippets, nearby docs, and any retrieved memory). It includes both the immediate prompt and the surrounding repository context the agent references.
  - Why it matters: Models can only reason over what they can see. Good context minimizes hallucination and reduces back-and-forth.
  - Best practices: Provide small, relevant excerpts (not whole files); point to durable docs (e.g., `docs/agents/*`); keep sensitive data out of context.

- Caching
  - What: Storing results from expensive operations (search results, compiled summaries, test outputs) to reuse across requests or sessions.
  - Why it matters: Reduces latency and API cost and keeps outputs stable for verification.
  - Best practices: Cache non-sensitive, reconstructible artifacts; include a TTL or version tag; invalidate caches when source files change.

- Tokens
  - What: The atomic billing/processing units used by LLMs (input + output). Token budgets limit how much context + response can be processed in one request.
  - Why it matters: Long contexts increase cost and may force truncation; short responses preserve tokens but may lose completeness.
  - Best practices: Keep prompts concise, summarize long files before including them, prefer retrieval-augmented prompts that pass small excerpts, and explicitly plan for token limits when designing verification flows.

## Agentic terms (short)

- RPIV: Research, Plan, Implement, Verify — the lean lifecycle used in this repo.
- AFK (Agent-implementable): A plan slice that can be implemented by the agent after explicit human approval (`EXECUTE`).
- HITL (Human-in-the-loop): A slice that requires human judgment, review, or external access before implementation.
- WORK.md: The single-file source of truth for a task at `.workflow/tasks/[source-id]/WORK.md` with guarded sections: `[BRIEF]`, `[GRILL]`, `[PLAN]`, `[LOG]`, `[META]`.
- Hats (Mindsets): Shell flags such as `--rpiv`, `--dev`, `--pm`, `--android` that preload appropriate skills and behaviors.
- Assisted-by: Commit footer to indicate AI assistance (human must still certify DCO / Signed-off-by when needed).
- EXECUTE: An explicit human instruction that authorizes the agent to perform filesystem-modifying actions for AFK slices.

## Practical tips

- Aim for minimal, precise context. A 1–2 paragraph summary plus a few key code snippets is usually sufficient.
- Use caching for expensive remote fetches or long summaries, but never cache secrets.
- Always label plan slices AFK vs HITL and include explicit verification commands.
- When in doubt about what to include in context, prefer adding a short pointer to a durable doc (e.g., `docs/agents/…`) rather than embedding large files.

## References
- Workflow: `docs/agents/norpiv.md`
- RPIV quick guide: `docs/agents/rpiv-workflow.md`
- Update durable docs: `pi/skills/norpiv/update-docs/SKILL.md`
