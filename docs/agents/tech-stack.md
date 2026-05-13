# Tech Stack Context

Durable technical rules for pi.dev workflows. Keep this file concise; detailed task evidence belongs in `.workflow/tasks/*/WORK.md`.

## Core Technologies
- **Pi Agent Configuration**: This repository is a `pi-package` that manages customizations, extensions, skills, prompts, and themes for the local `pi` coding agent.
- **Node.js / TypeScript**: Used for creating and modifying `pi` extensions (located in `pi/extensions/`).
- **Bash**: Used for automation and deployment scripts (located in `scripts/` and skill folders).

## Technical Rules & Conventions

### 1. Pi Extensions (`pi/extensions/`)
- Write extensions in **TypeScript** (`.ts`).
- Keep extensions as small, single-file implementations when possible.
- Align provider and model names with the public API they wrap.
- Refer to `docs/extensions.md` in the pi SDK documentation for API structures.

### 2. Bash Scripts (`scripts/`)
- Ensure scripts are executable (`chmod +x`).
- Avoid hardcoded paths; use variables resolved relative to the script's directory.

### 3. Deployment Constraint
- **NEVER** edit files directly in `~/.pi/`.
- All development and modification of skills, extensions, and prompts must occur within this repository (`pi.dev`).
- Execute `./scripts/setup.sh` to deploy local repository changes to the active `~/.pi/` workspace.

### 4. Code Quality & Testing
- Adhere to the existing patterns found in the `pi/extensions/` and `pi/skills/` directories.
- Do not introduce new heavy frameworks unless absolutely necessary for a new extension.
