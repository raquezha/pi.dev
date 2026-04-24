# Pi Agent Skills

This directory contains specialized skills for the `pi` coding agent. Skills are organized by category.

## Categories

### 📱 [Android](./android/ROADMAP.md)
Core skills for Android development.
- **Status**: 🟢 Core Tooling Done
- **Next Up**: Manifest & Resource Management, Test Automation.

### 🔍 Search
Web search and information retrieval.
- **Status**: 🟢 Brave Search Integrated
- **Next Up**: Content extraction, Goggles integration.

### ♾️ GitLab & DevOps (Planned)
Skills for managing GitLab CI/CD pipelines, MR reviews, and environment deployments.
- **Status**: ⚪ Planned

### 🚀 Mobile DevOps (Planned)
Skills for Fastlane, App Store/Play Store automated releases, and TestFlight management.
- **Status**: ⚪ Planned

### 🛠 Meta
Skills for creating and maintaining pi skills and other agent-facing building blocks.
- **Status**: 🟢 Pi Skill Creator Added
- **Skills**: `meta/pi-skill-creator`
- **Notes**: `pi-skill-creator` is pi.dev-first; it can study external repos as source material but should normally generate reusable skills back into `pi/skills/...` in this repository unless the user explicitly wants a project-local skill.

### ✍️ Documentation (Planned)
Skills for generating API docs, maintaining READMEs, and technical writing assistance.
- **Status**: ⚪ Planned

---

## How to Add Skills
1. Create a category directory (e.g., `devops/`).
2. Create a skill directory inside it (e.g., `gitlab-mr/`).
3. Add a `SKILL.md` file with frontmatter (name and description).
4. If the skill is based on an external repo or workflow, treat that source as context and create the reusable skill here under `pi/skills/...` unless you intentionally want a project-local skill elsewhere.
5. Run `./scripts/setup.sh` to update symlinks.
6. In pi, run `/reload` to pick up the new or updated skill.
