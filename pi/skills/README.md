# Pi Agent Skills

This directory contains specialized skills for the `pi` coding agent. Skills are organized by category.

## Categories

### 📱 [Android](./android/ROADMAP.md)
Core skills for Android development.
- **Status**: 🟢 Core Tooling Done
- **Next Up**: Manifest & Resource Management, Test Automation.
- **Skills**: `android-adb`, `android-agp9-migration`, `android-compose`, `android-gradle`, `android-logcat-smart`, `android-project-setup`, `android-ci-component-adoption`

### 🔍 Search
Web search and information retrieval.
- **Status**: 🟢 Brave Search + Firecrawl Integrated
- **Skills**: `brave-search`, `firecrawl`
- **Extension**: `search-subagent` spawns isolated child pi sessions for search work.
- **Notes**: `./scripts/setup.sh` links this category into `~/.pi/agent/skills/` so `/skill:...` works without hats.
- **Next Up**: Content extraction, Goggles integration.

### ♾️ GitLab & DevOps (Planned)
Skills for managing GitLab CI/CD pipelines, MR reviews, and environment deployments.
- **Status**: ⚪ Planned

### 🔁 Workflow
Core RPIV workflow skills for task intake, framing, planning, implementation, verification, tracker sync, and documentation upkeep.
- **Status**: 🟢 Lean RPIV Added
- **Skills**: `triage`, `frame`, `grill-with-docs`, `plan`, `implement`, `verify`, `sync`, `update-docs`, `cleanup`

### 🚀 Mobile DevOps (Planned)
Skills for Fastlane, App Store/Play Store automated releases, and TestFlight management.
- **Status**: ⚪ Planned

### 🛠 Meta
Skills for creating and maintaining pi skills and other agent-facing building blocks.
- **Status**: 🟢 Pi Skill Creator & Agent-OS Added
- **Skills**: `meta/pi-skill-creator`, `meta/agent-os`
- **Notes**: `pi-skill-creator` is pi.dev-first; it can study external repos as source material but should normally generate reusable skills back into `pi/skills/...` in this repository unless the user explicitly wants a project-local skill.

### ✍️ Documentation / Context Curation
Skills for keeping durable repo documentation and agent context aligned without context bloat.
- **Status**: 🟢 Context Curation Added
- **Skills**: `workflow/update-docs`
- **Notes**: `update-docs` updates durable docs such as `AGENTS.md`, `README.md`, skill docs, and `docs/agents/*`; task-specific state stays in `.workflow/tasks/*/WORK.md`.

---

## How to Add Skills
1. Create a category directory (e.g., `devops/`).
2. Create a skill directory inside it (e.g., `gitlab-mr/`).
3. Add a `SKILL.md` file with frontmatter (name and description).
4. If the skill is based on an external repo or workflow, treat that source as context and create the reusable skill here under `pi/skills/...` unless you intentionally want a project-local skill elsewhere.
5. Run `./scripts/setup.sh` to update symlinks.
6. In pi, run `/reload` to pick up the new or updated skill.
