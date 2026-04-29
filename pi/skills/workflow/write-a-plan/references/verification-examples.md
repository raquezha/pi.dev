# Verification Examples (Non-Dev / Non-Code)

This reference helps the agent create "Tests" for non-coding tasks.

### 1. Documentation Tasks
- **Phase 0 (Test):** Search for a specific concept in the docs.
- **Verification:** `grep -r "ConceptName" ./docs` -> Should return 0 results.
- **Success:** The same command returns the correct file and line.

### 2. Organization / File Tasks
- **Phase 0 (Test):** List files that lack a specific tag or structure.
- **Verification:** `find . -maxdepth 1 -not -name "*.md"`
- **Success:** The command returns nothing (all files are now .md).

### 3. Research Tasks
- **Phase 0 (Test):** Check the local "Knowledge Base" for a tool.
- **Verification:** `cat RESEARCH.md` -> Result: "Empty" or "TBD".
- **Success:** The file contains 3 pros, 3 cons, and a recommendation.

### 4. CI/CD Pipeline (Infrastructure as Code)
- **Phase 0 (Test):** Run a "Dry Run" or Lint check on a new config.
- **Verification:** `glab ci lint` or `terraform plan`.
- **Success:** The lint passes or the plan shows the expected resources to be created.
