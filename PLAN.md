# RPIV Workflow Engine — PLAN.md
> Last Updated: 2026-06-07
> Status: Migrated to `nothing/`; `pi.dev` archived for historical reference

---

## 🎯 The Goal
Build a "Staff Engineer" grade agentic workflow engine that:
- Fetches tasks from Jira/GitHub/GitLab.
- Organizes work in namespaced, git-ignored folders.
- Enables safe, reviewable AI-assisted implementation with clear human handoff.
- Keeps the PM happy via tracker sync when appropriate.
- Positions the developer as the **Orchestrator**, not the coder.
- Preserves `nothing` philosophy: default Pi stays close to vanilla, first-party workflow stays local, third-party optimizers remain optional modifiers.

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

## 🎩 Base Hats and Modifiers (`shell_integration.sh`)

### Base hats

| Hat | Command | Purpose |
| :--- | :--- | :--- |
| **Nothing** | `pi --nothing` | Explicit near-vanilla mode. Load no workflow extras beyond minimal nothing bootstrap behavior. |
| **RPIV (full)** | `pi --rpiv` | Local first-party RPIV workflow: triage, frame, grill-with-docs, plan, implement, verify, sync, update-docs, cleanup. |
| **Android** | `pi --android` | Active Android development mode: RPIV execution helpers + local vendored Android skills. No MCP. No global Android skill dependency. |
| **PM** | `pi --pm` | Local PM-oriented workflow: search, triage, frame, grill-with-docs, plan, sync. |
| **Dev** | `pi --dev` | Local implementation/verification workflow: search, triage, implement, verify, sync, cleanup. |
| **Meta** | `pi --meta` | Local meta/skill-authoring helpers and environment protection tools. |
| **Write** | `pi --write` | Local writing and documentation helpers. |
| **Antigravity** | `pi --antigravity` | Experimental extension-focused mode. |

### Additive modifiers

| Modifier | Command | Purpose |
| :--- | :--- | :--- |
| **Caveman** | `--caveman` | Optional third-party response-compression modifier. Global install is acceptable because it is additive, not first-party workflow source of truth. |
| **RTK** | `--rtk` | Optional experimental command-output compression modifier. Treat as opt-in and machine-level until proven stable with Pi. |

### Hat rules

- Base hats define primary persona/workflow.
- Modifiers are additive and must not replace first-party local skill loading.
- `--nothing` is explicit escape hatch for clean/near-vanilla startup; current implementation lets `--nothing` win and ignores additive modifiers with a warning.
- Avoid dedicated `--plan` / `--implement` hats unless needed later; keep persona surface small.

---

## 🧩 Skills Map (`nothing/packages/norpiv/`)

| Skill | Status | Notes |
| :--- | :--- | :--- |
| `triage` | ✅ Created | Writes `WORK.md` and `metadata.json`.
| `frame` | ✅ Created | Writes `[BRIEF]` only; never create `PROBLEM.md` / `PRD.md`.
| `grill-with-docs` | ✅ Created | Reads `CONTEXT.md` and `docs/agents/*`.
| `plan` | ✅ Created | Writes `[PLAN]` only; never implement during planning.
| `implement` | ✅ Created | Implements one slice, appends to `[LOG]`.
| `verify` | ✅ Created | Runs verification and updates `[LOG]`.
| `sync` | ✅ Created | Tracker sync helper.
| `cleanup` | ✅ Created | Auxiliary hygiene skill. Repo/task cleanup utility, not strict RPIV phase.

---

## 🔧 The Wiring

- **`nothing/packages/norpiv/scripts/triage_helper.sh`**: Helper used by `triage` to create `.workflow/tasks/[source-id]/` and populate `WORK.md` and `metadata.json` from remote APIs (`gh`, `glab`, `jira`).
- **`pi/shell_integration.sh` / `nothing/dotfiles/shell_integration.sh`**: Provides base hats plus additive modifiers. Base hats should load first-party skills from local repo paths, not from global installs.
- **Bootstrap strategy**: Bootstrap should install Pi, settings, shell wiring, and published extensions. It must not make first-party workflow correctness depend on global skill installs.
- **First-party skills**: `norpiv`, `nometa`, `nosearch`, and other owned workflow assets stay local/symlinked from repo so active development always uses checked-out source.
- **Third-party skills**: Global install is acceptable only for optional add-ons/modifiers that are not workflow source of truth (e.g. `caveman`, maybe `caveman-stats`).
- **Local Android skills**: Official `android/skills` should be vendored repo-locally (prefer git subtree) and loaded by `pi --android`; do not depend on MCP or global skill installs for owned Android workflow.
- **Android starting set**: Begin with `android-cli`, then curate additional local Android skills only when they prove useful in real work.
- **RTK strategy**: Treat RTK as optional experiment. Do not make it default bootstrap behavior or mandatory shell wiring until Pi-specific value is proven.
- **`scripts/setup.sh`**: Intentionally skips linking some large context files (AGENTS.md, skills). Review if symlink behavior should change.
- **`docs/agents/`**: Durable, anti-bloat memory for domain and tech rules.

---

## ✅ Initial Implementation Snapshot (`nothing/`)

1. **Nothing-mode precedence:** Implemented as clean mode. `pi --nothing` loads zero configured skills/extensions and ignores `--caveman` / `--rtk` with a warning.
2. **Android vendoring:** Implemented as local vendor snapshot at `vendor/android-skills/`. MCP removed from `settings.json`. Bootstrap no longer globally installs `android/skills`.
3. **Android hat curation:** Implemented initial `pi --android` loading: RPIV execution helpers + local `vendor/android-skills/devtools/android-cli` + `noagy`.
4. **Local-vs-global boundary:** First-party hats resolve repo-local paths first. Bundled skill installers are only for optional global discovery/symlinks, not hat correctness.
5. **Third-party modifier policy:** `--caveman` implemented as additive modifier using global `~/.pi/agent/skills/caveman` and `caveman-stats`. Bootstrap installs those via `npx skills add JuliusBrussee/caveman`.
6. **RTK experiment path:** `--rtk` implemented as reserved/experimental modifier marker. It warns if `rtk` is missing and does not mutate shell hooks automatically.

## ⏳ Pending Decisions & Notes

1. Decide whether `vendor/android-skills/` should remain a snapshot managed by `scripts/sync-android-skills.sh` or be converted to a true git subtree later.
2. Expand `pi --android` curated skill set only after real usage justifies additions beyond `android-cli`.
3. Decide RTK integration depth after manual testing: no-op marker, doc-only install, bootstrap flag, or true Pi hook integration.
4. `.workflow/` is intentionally at repo root and is already listed in `.gitignore`.
5. Skills in `nothing/packages/norpiv/` are implemented to use `WORK.md` guarded sections; verify other skills follow same contract.

---

