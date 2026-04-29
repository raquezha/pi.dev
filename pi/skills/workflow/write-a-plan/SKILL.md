---
description: Generate a TDD-first PLAN.md file based on a Problem.md or chat context. This is the core "Planner" skill for the R&D Agentic Workflow, covering code (Android, CI/CD) and non-code tasks.
---

# Skill: write-a-plan

Transform a problem into a phased, verifiable implementation strategy with a mandatory TDD (Phase 0) start.

## Core Process
1. **Analyze Input**: Read `Problem.md` and current project context. Determine if this is a **Code Task** or a **Non-Code Task**.
2. **Select Verification Method**:
   - *Code:* Identify the test framework (JUnit, Jest, etc.) and the specific test to write.
   - *Non-Code:* Identify a "proof of failure" check (e.g., a grep command or a manual observation).
3. **Draft Decision Tree**: Evaluate at least two ways to solve the problem. Pick the best one and explain why.
4. **Generate PLAN.md**: Use `references/universal-template.md` to build the plan.
5. **Phase 0 (Mandatory)**: Every plan must start with "Phase 0: Failing Test / Proof of Failure."
6. **Risk Audit**: Identify 2-3 potential blockers or "gotchas."

## Universal Phases
Regardless of the project type, use this structure:
- **Phase 0: The Feedback Loop (TDD)**: Create the failing test or proof of current failure.
- **Phase 1: Foundations**: Set up data structures, schemas, or base config.
- **Phase 2: Mechanics**: Implement the core logic, presenters, or processing loops.
- **Phase 3: Integration**: Connect to the UI, CLI, or external systems.

## Rules
- **TDD-First**: Do not skip Phase 0.
- **Atomic Steps**: Each step should be small enough to be a single commit.
- **Verification-Heavy**: Every phase must end with a "Verification Command."
- **Premium Model Switch**: After generating the plan, recommend the user switch to a premium model for implementation.

## Quality Bar
- Does the plan solve the "Success Criteria" from `Problem.md`?
- Is there a clear "Rollback" strategy?
- Are Non-Goals respected?
