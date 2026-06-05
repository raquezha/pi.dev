# Monorepo Migration Plan: Transition to "nothing"

> Last Updated: 2026-06-05
> Status: Planning & Refinement (Approved)

---

## 🎯 1. Overview & Goals
The goal is to replace the platform-specific setups, symlinks, and duplicate directories in `pi.dev` with a clean, package-based monorepo installer named **`nothing`**. This workspace will configure Zsh/Bash shells identically on **macOS** and **Linux** without repository bloat or update drift.

---

## 🏛️ 2. Architectural Design Decisions

### 2.1. Dynamic Android Guidelines (No Copies or Clones)
* **Decision**: We explicitly rejected physically copying or cloning Google's canonical [android/skills](https://github.com/android/skills) files into our repositories.
* **Rationale**: Upstream changes by Google would immediately cause **update drift** in our static folders. Instead, we dynamically query the guidelines on-demand using the **MCP Server** registry (`npx -y android-skills-mcp`) configured in `settings.json`.

### 2.2. Isolated Workspaces via Git Worktrees
* **Decision**: RPIV task workspaces will instantiate isolated Git Worktrees inside the task folders during implementation.
* **Rationale**: Prevents workspace contamination, removes the need to `git stash` half-completed tasks when context-switching, allows parallel testing without race conditions, and leaves the main repository directory clean.

### 2.3. Package-Based Extension Registry
* **Decision**: Publish custom tools (such as `notrace`) directly to the **NPM registry** rather than symlinking files locally.
* **Rationale**: Standardizes installation across macOS and Linux, simplifies environment discovery, and enables version-pinned upgrades.

### 2.4. Removal of `default_models` Configuration
* **Decision**: Eliminated the hardcoded `default_models` list from settings, relying purely on the mindset configuration profiles.
* **Rationale**: Eliminates redundancy and keeps config files clean.

---

## 📂 3. Repository Blueprint Tree (`nothing/`)

```text
nothing/
├── bootstrap.sh                  # Detects OS, installs toolchains, mounts settings
├── mindsets.json                 # Defines mindsets (--rpiv, --dev, --pm, --android, --meta)
├── settings.json                 # Global agent settings and MCP server blocks
├── dotfiles/
│   └── shell_integration.sh      # Parses custom mindset flags and resolves package paths
├── packages/                     # Monorepo packages (using consistent "no-" prefix)
│   ├── norpiv/                   # Lean RPIV workflow orchestrator skills
│   ├── notrace/                  # HTML telemetry and trace viewer extension
│   ├── noleaks/                  # Security credentials protector shield extension
│   ├── nosearch/                 # Integrated Search skills & background subagent wrapper
│   ├── noantigravity/            # OAuth login provider extension
│   ├── nometa/                   # Meta skills (pi-skill-creator, agent-os, nothing-bootstrap, md-to-html)
│   └── nofooter/                 # CLI powerline footer theme extension
└── .github/
    └── workflows/
        └── sync-upstream-skills.yml # Auto-sync action fetching updates from android/skills
```

---

## 🏷️ 4. Naming Transitions (Nomenclature Alignment)

Every core block is anchored to a standard `no-` prefix naming convention to signify isolation and lightweight footprint:

| Old Repository Path | New Monorepo Package | Type | Purpose |
| :--- | :--- | :--- | :--- |
| `workflow/` | `packages/norpiv/` | Skill | RPIV orchestrator skills |
| `html-observability/` | `packages/notrace/` | Extension | HTML trace collector |
| `env-protection/` | `packages/noleaks/` | Extension | Credentials protector |
| `search-subagent/` & `search/` | `packages/nosearch/` | Integrated | Search skills & subagent wrapper |
| `antigravity-auth-login/` | `packages/noantigravity/` | Extension | OAuth login utility |
| `powerline-footer/` | `packages/nofooter/` | Extension | Terminal layout theme |
| `meta/` | `packages/nometa/` | Skill | Meta systems and skill generators |

---

## 📋 5. Timeline Checklist & Status

### Phase 1: Local Refactoring & Renaming
* [x] **Task 1.1**: Rename RPIV workflow skills ➔ `norpiv`.
* [x] **Task 1.2**: Rename core triage scripts ➔ `norpiv`.
* [x] **Task 1.3**: Rename credentials protector ➔ `noleaks`.
* [x] **Task 1.4**: Rename html trace collector ➔ `notrace`.
* [x] **Task 1.5**: Rename other extensions (`nofooter`, `nosearch`, `noantigravity`).

### Phase 2: Packaging Custom Extensions
* [x] **Task 2.1**: Restructure `notrace` to support standard Node compile (`tsconfig.json`).
* [x] **Task 2.2**: Scaffolding package specifications (`package.json`) for custom extensions.
* [x] **Task 2.3**: Establish private scopes for npm distribution.
* [ ] **Task 2.4**: Publish built packages to NPM.

### Phase 3: Building "nothing" Monorepo
* [x] **Task 3.1**: Write cross-platform `bootstrap.sh` installer.
* [x] **Task 3.2**: Extract declarative mindset configurations to `mindsets.json`.
* [x] **Task 3.3**: Integrate dynamically-resolving path loaders in shell integrations.
* [ ] **Task 3.4**: Write visual, comprehensive READMEs for each monorepo package.
* [ ] **Task 3.5**: Implement `md-to-html` plan dashboard compiler in `nometa`.

### Phase 4: Transition & Verification
* [ ] **Task 4.1**: Verify `bootstrap.sh` execution and setups on macOS Darwin.
* [ ] **Task 4.2**: Verify `bootstrap.sh` execution and setups on Linux environments.
* [ ] **Task 4.3**: Validate telemetry trace viewer output compilation.

### Phase 5: Automated Workflows (GitHub Actions)
* [ ] **Task 5.1**: CI Validation (`ci-validate.yml`) running `shellcheck` and linting configs.
* [ ] **Task 5.2**: Upstream Guidelines Auto-Sync (`sync-upstream-skills.yml`) creating review PRs.
* [ ] **Task 5.3**: CD Publishing Workflow (`publish-packages.yml`) triggering on tag releases.

---

## 🛠️ 6. Blueprints & Configurations

### 6.1. Cross-Platform `bootstrap.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail

# 1. Detect OS Platform
OS="$(uname -s)"
case "$OS" in
  Darwin)
    echo "Installing tools via Homebrew..."
    brew install node tmux git gh go
    ;;
  Linux)
    echo "Installing tools via apt-get..."
    if command -v apt-get &>/dev/null; then
      sudo apt-get update && sudo apt-get install -y nodejs npm tmux git github-cli golang
    fi
    ;;
esac

# 2. Install Pi Coding Agent and extensions globally from NPM
echo "Installing packages from NPM..."
npm install -g @mariozechner/pi-coding-agent
npm install -g notrace noleaks

# 3. Mount configurations
mkdir -p "$HOME/.pi/agent"
cp settings.json "$HOME/.pi/agent/settings.json"
echo "Bootstrap complete! 🎉"
```

### 6.2. Mindsets Configuration (`mindsets.json`)
```json
{
  "mindsets": {
    "nothing": {
      "skills": ["nometa/nothing"],
      "extensions": []
    },
    "android": {
      "skills": ["norpiv/triage", "norpiv/implement", "norpiv/verify"],
      "extensions": []
    },
    "pm": {
      "skills": ["nosearch", "norpiv/triage", "norpiv/frame", "norpiv/grill-with-docs", "norpiv/plan", "norpiv/sync"],
      "extensions": []
    },
    "dev": {
      "skills": ["nosearch", "norpiv/triage", "norpiv/implement", "norpiv/verify", "norpiv/sync", "norpiv/cleanup"],
      "extensions": ["notrace"]
    },
    "rpiv": {
      "skills": ["nosearch", "norpiv/triage", "norpiv/frame", "norpiv/grill-with-docs", "norpiv/plan", "norpiv/implement", "norpiv/verify", "norpiv/sync", "norpiv/update-docs", "norpiv/cleanup"],
      "extensions": ["notrace"]
    },
    "meta": {
      "skills": ["nometa", "nosearch"],
      "extensions": ["noleaks"]
    },
    "write": {
      "skills": ["nosearch"],
      "extensions": []
    },
    "antigravity": {
      "skills": [],
      "extensions": ["noantigravity"]
    }
  }
}
```

### 6.3. Default Agent Settings (`settings.json`)
```json
{
  "defaultProvider": "groq",
  "theme": "dracula-vibrant",
  "packages": [],
  "noleaks": true,
  "mcpServers": {
    "android-skills": {
      "command": "npx",
      "args": ["-y", "android-skills-mcp"]
    }
  }
}
```

### 6.4. Git-Worktree RPIV Flow (`norpiv/WORK.md` Anatomy)
```markdown
# TASK: github-42 — Implement dynamic route loading

## [BRIEF]
- Goal: Replace static router definitions in packages/app with dynamic code-splitted routes.
- Constraints: Maintain 100% test coverage; do not bundle admin routes into the user bundle.
- Context: Target files are `src/router.ts` and `src/main.ts`.

## [GRILL]
- Q: Did we check if import() is supported in our targeted browsers?
  A: Yes, target is modern browsers only.
- Q: What happens if dynamic loading fails (e.g. network disconnect)?
  A: Must show a retry banner/boundary.

## [PLAN]
- [x] Slice 1: Setup React.lazy boundaries and error boundary wrappers.
- [ ] Slice 2: Implement dynamic import mapping for core route configurations.
- [ ] Slice 3: Add integration tests verifying route splits.

## [LOG]
### 2026-06-05 09:15:00 — Slice 1 Completed
- Created `src/components/SafeRouteLoader.tsx` error fallback.
- Added tests in `tests/SafeRouteLoader.test.tsx`.
- Verification run: `npm run test` (Passed, 2 tests).
```

### 6.5. Upstream Skills Sync Workflow (`sync-upstream-skills.yml`)
```yaml
name: Sync Upstream Android Skills
on:
  schedule:
    # Run weekly (Sundays at midnight)
    - cron: '0 0 * * 0'
  workflow_dispatch: # Allow manual triggering

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout nothing repository
        uses: actions/checkout@v4

      - name: Clone official android/skills repository
        run: |
          git clone --depth 1 https://github.com/android/skills.git upstream_skills

      - name: Synchronize guidelines to packages/android/
        run: |
          mkdir -p packages/android
          # Synchronize files while retaining local exclusions or customizations
          rsync -av --delete --exclude='.git' upstream_skills/ packages/android/
          rm -rf upstream_skills

      - name: Create reviewable Pull Request if modifications exist
        uses: peter-evans/create-pull-request@v6
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          commit-message: "chore(android): sync guidelines with official upstream repo"
          title: "🔄 Update Official Android Guidelines"
          body: |
            This automated Pull Request syncs the local `packages/android/` guidelines
            with the canonical upstream repository: https://github.com/android/skills.
            Please review the diff before merging to check for rules and prompts updates.
          branch: android-skills-sync
          delete-branch: true
```
