# RPIV Workflow Engine — PLAN.md
> Last Updated: 2026-05-07
> Status: Discussion Phase (NOT APPROVED FOR EXECUTION)

---

## 🎯 The Goal
Build a "Staff Engineer" grade agentic workflow engine that:
- Fetches tasks from Jira/GitHub/GitLab.
- Organizes work in namespaced, git-ignored folders.
- Follows the Linux Kernel contribution standards.
- Keeps the PM happy via automated Jira sync.
- Positions the developer as the **Orchestrator**, not the coder.

---

## 🗺️ The RPIV Flow

| Phase | Command | What it does | Artifact |
| :--- | :--- | :--- | :--- |
| **R (Research)** | `/triage [source]:[id]` | Fetches issue, creates namespace | `WORK.md` (init) |
| **R (Research)** | `/frame` | Defines Bug or Feature | `WORK.md` (Problem/PRD) |
| **R/P (Refine)** | `/grill-with-docs` | Stress-tests plan vs codebase | `WORK.md` + `docs/agents/` |
| **P (Plan)** | `/plan` | Maps vertical slices | `WORK.md` (Slices) |
| **I (Implement)** | `/implement` | Codes one slice, opens Draft MR | Code + MR |
| **V (Verify)** | `/verify` | Tests, Jira sync, Kernel commit | Done |

---

## 📂 Directory Structure

```bash
.workflow/                        # Git-ignored GLOBALLY (~/.gitignore_global)
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
| **Plan** | `pi --plan` | triage, frame, grill-with-docs, plan |
| **Implement** | `pi --implement` | implement, verify |
| **Full RPIV** | `pi --rpiv` | ALL of the above + search |
| **Android** | `pi --android` | Android-specific skills (modifier) |
| **DevOps** | `pi --devops` | CI/CD-specific skills (modifier) |

---

## 🧩 Skills Map (pi/skills/workflow/)

| Skill | Status | Replaces |
| :--- | :--- | :--- |
| `triage` | ✅ Created | `investigate` |
| `frame` | ✅ Created | `frame-problem` |
| `grill-with-docs` | ✅ Created | `ubiquitous-language` |
| `plan` | ✅ Created | `write-a-plan` |
| `implement` | ✅ Created | `implement-plan` |
| `verify` | ✅ Created | `verify-changes` |
| `to-jira` | ✅ Created | (new) |

---

## 🔧 The Wiring

- **`pi/scripts/workflow/triage_helper.sh`**: Bash script that creates the `.workflow/tasks/[source]-[id]/` folder and populates `WORK.md` using `gh`, `glab`, or `jira` CLI.
- **`pi/shell_integration.sh`**: Updated to include `--plan`, `--implement`, and `--rpiv` hats.
- **`scripts/setup.sh`**: Needs to be updated to wire the new skills.
- **`docs/agents/`**: Anti-bloat modular memory (domain.md, tech-stack.md, workflow.md).

---

## ⏳ Pending Decisions

1. **`--rpiv` wiring**: Not yet wired in `shell_integration.sh`.
2. **`setup.sh` wiring**: Not yet updated.
3. **Global gitignore**: `.workflow/` not yet added to `~/.gitignore_global`.
4. **`WORK.md` as Source of Truth**: Skills not yet updated to explicitly point to `WORK.md`.
5. **`triage_helper.sh` path**: Should the `.workflow/` folder be at repo root (not `.pi/workflow/`)?
