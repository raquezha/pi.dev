# RPIV Workflow Engine — PLAN.md
> Last Updated: 2026-05-11
> Status: Discussion Phase (NOT APPROVED FOR EXECUTION)

---

## 🎯 The Goal
Build a "Staff Engineer" grade agentic workflow engine that:
- Fetches tasks from Jira/GitHub/GitLab.
- Organizes work in namespaced, git-ignored folders.
- Enables safe, reviewable AI-assisted implementation with clear human handoff.
- Keeps the PM happy via tracker sync when appropriate.
- Positions the developer as the **Orchestrator**, not the coder.

---

## 🗺️ The RPIV Flow

| Phase | Command | What it does | Artifact |
| :--- | :--- | :--- | :--- |
| **R (Research)** | `/triage [source]:[id]` | Fetches issue, creates or resumes the namespaced workspace | `.workflow/tasks/[source-id]/WORK.md` (init) |
| **R (Research)** | `/frame` | Produce a concise brief in `WORK.md` -> `[BRIEF]` (no separate PROBLEM/PRD files) | `WORK.md` (`[BRIEF]`) |
| **R/P (Refine)** | `/grill-with-docs` | Stress-test the brief and plan against `CONTEXT.md`, `docs/agents/*`, and code rules | `WORK.md` + `docs/agents/` |
| **P (Plan)** | `/plan` | Draft thin, verifiable vertical slices in `[PLAN]` and mark AFK/HITL | `WORK.md` (`[PLAN]`) |
| **I (Implement)** | `/implement` | Execute the next approved slice, run verification, open Draft PR/MR | Code + Draft PR/MR + `WORK.md` (`[LOG]`) |
| **V (Verify)** | `/verify` | Run verification commands and gates; append evidence and recommend sync | `WORK.md` (`[LOG]`) / tracker sync |

---

## 📂 Directory Structure

```bash
.workflow/                        # Git-ignored
  tasks/
    jira-PROJ-123/
      WORK.md                     # The "One File" (Source of Truth)
      metadata.json               # Raw data from remote
    github-42/
      WORK.md
      metadata.json
  active_task.json                # Pointer to current task
```

---

## 🎩 The Hats (shell_integration.sh)

| Hat | Command | Skills Loaded |
| :--- | :--- | :--- |
| **RPIV (full)** | `pi --rpiv` | triage, frame, grill-with-docs, plan, implement, verify, sync, update-docs |
| **Android** | `pi --android` | Android-specific skills (modifier) |
| **PM** | `pi --pm` | search, triage, frame, grill-with-docs, plan, sync |
| **Dev** | `pi --dev` | search, triage, implement, verify, sync |
| **Meta** | `pi --meta` | meta skill creation, noleaks helpers |
| **Write** | `pi --write` | documentation and writing-focused skills |
| **Antigravity** | `pi --antigravity` | loads antigravity experimental extension |

> Note: the shell integration currently provides the hats above. Consider adding dedicated `--plan` or `--implement` hats if a lightweight persona is desired.

---

## 🧩 Skills Map (pi/skills/norpiv/)

| Skill | Status | Notes |
| :--- | :--- | :--- |
| `triage` | ✅ Created | Writes `WORK.md` and `metadata.json`.
| `frame` | ✅ Created | Writes `[BRIEF]` only; never create `PROBLEM.md` / `PRD.md`.
| `grill-with-docs` | ✅ Created | Reads `CONTEXT.md` and `docs/agents/*`.
| `plan` | ✅ Created | Writes `[PLAN]` only; never implement during planning.
| `implement` | ✅ Created | Implements one slice, appends to `[LOG]`.
| `verify` | ✅ Created | Runs verification and updates `[LOG]`.
| `to-jira` | ✅ Created | Tracker sync helper.

---

## 🔧 The Wiring

- **`pi/scripts/norpiv/triage_helper.sh`**: Helper used by `triage` to create `.workflow/tasks/[source-id]/` and populate `WORK.md` and `metadata.json` from remote APIs (`gh`, `glab`, `jira`).
- **`pi/shell_integration.sh`**: Provides hats that preload skill sets (see Hats above).
- **`scripts/setup.sh`**: Intentionally skips linking some large context files (AGENTS.md, skills). Review if symlink behavior should change.
- **`docs/agents/`**: Durable, anti-bloat memory for domain and tech rules.

---

## ⏳ Pending Decisions & Notes

1. Decide whether to add dedicated `--plan` / `--implement` hats to `pi/shell_integration.sh` or continue using `--rpiv`/`--dev` personas.
2. Decide whether `PLAN.md` (this file) remains a committed planning artifact or is moved to an ephemeral workspace; prefer keeping durable rules only in `docs/agents/`.
3. Review `scripts/setup.sh` symlink behavior for repo-local extensions; avoid auto-linking large context files by default.
4. `.workflow/` is intentionally at the repo root and is already listed in `.gitignore`.
5. Skills in `pi/skills/norpiv/` are implemented to use `WORK.md` guarded sections; verify other skills follow the same contract.

---

