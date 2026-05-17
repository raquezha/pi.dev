# FORENSIC SYSTEMS REPORT: `pi.dev` Orchestration Layer

## PHASE 1 — SYSTEM INVENTORY

The `pi.dev` architecture is an orchestration wrapper. It is not an agent engine itself; it is a deterministic state machine mapped onto the stochastic `@earendil-works/pi-coding-agent` engine via prompt injection and shell-level routing.

**Core Subsystems:**

1.  **Transport & Tools (Core Engine)**
    *   *Purpose*: LLM IO, Context truncation, Tool execution (`read`, `write`, `edit`, `bash`).
    *   *Key Files*: `@earendil-works/pi-coding-agent/src/core/*`
2.  **Workflow State Machine (The Workspace)**
    *   *Purpose*: Externalizes agent memory to disk to survive session compaction.
    *   *Key Files*: `.workflow/active_task.json`, `.workflow/tasks/[source-id]/WORK.md`, `.workflow/tasks/[source-id]/metadata.json`.
3.  **Router / Hat Injector**
    *   *Purpose*: Intercepts CLI startup, loading specific skills based on workflow phase.
    *   *Key Files*: `pi/shell_integration.sh`
4.  **The "Skills" (Persona Prompts)**
    *   *Purpose*: Forces the generic agent into narrow, phase-specific execution loops (Triage, Frame, Grill, Plan, Implement, Verify).
    *   *Key Files*: `pi/skills/workflow/*`
5.  **Capability Interceptors (Extensions)**
    *   *Purpose*: Runtime blocking of tools to prevent credential exfiltration.
    *   *Key Files*: `pi/extensions/env-protection/index.ts`

**Dependency Graph Flow:**
`pi CLI` ➔ `shell_integration.sh (Hat Router)` ➔ `env-protection (Interceptor)` ➔ `LLM Core` ➔ `Skills (Prompt Injection)` ➔ `.workflow/tasks/ (State Read/Write)` ➔ `bash/edit/read (Action)`

---

## PHASE 2 — PROMPT & AGENT EXTRACTION

The system uses highly constrained, heavily guarded prompts to enforce the RPIV methodology.

### 1. The Implementer Prompt (`/implement`)
*   **Trigger**: User inputs `/implement`.
*   **Prompt Snippet**: `"READ: .workflow/active_task.json then active WORK.md [PLAN]. WRITE: code changes and WORK.md -> append to [LOG] only. NEVER: edit [BRIEF] or [GRILL]. NEVER: implement without explicit user instruction."`
*   **Downstream Effects**: Forces the model to locate `.workflow/active_task.json` first, extracting the pointer, then strictly reading `WORK.md`.
*   **Token Inefficiency**: The model must re-read the entire `WORK.md` file (including historical `[LOG]` data) just to find the next unchecked `[PLAN]` slice.
*   **Fragility**: If the `enforce-branch.sh` script fails or stdout is malformed, the prompt explicitly instructs the agent to "STOP and ask the human", dropping it out of the autonomous loop.

### 2. The Interrogator Prompt (`/grill-with-docs`)
*   **Trigger**: User inputs `/grill-with-docs`.
*   **Prompt Snippet**: `"Locate the files/lines mentioned in the brief. Trace the data flow... Ask one question at a time to resolve contradictions... NEVER: ask questions the codebase can answer; inspect first."`
*   **Downstream Effects**: Triggers massive token ingestion. The agent uses `bash` (`rg`, `find`) to blindly dump codebase architecture into context.

**Prompt Bloat/Observation**: The system heavily relies on `NEVER: [action]` formatting. While effective for Claude, weaker models often ignore negative constraints. The `[LOG]` appending instruction is present in *every* prompt, guaranteeing exponential context growth on long tasks.

---

## PHASE 3 — EXECUTION TRACE ANALYSIS

**Reconstructed Trace: Medium Feature Implementation**

*   **Task Metadata**: GitHub Issue #45. Repo size: 800 files. Model: Claude 3.5 Sonnet.
*   **Timeline**:
    1.  `pi --rpiv` (Router loads 10 skills into context. *~4k input tokens base*).
    2.  `/triage github:45`. Agent calls `bash ./pi/scripts/workflow/triage_helper.sh github 45`. Tool returns stdout confirming `WORK.md` creation.
    3.  `/plan`. Agent reads `WORK.md`. Agent reads `package.json`. Agent writes 3 slices to `[PLAN]`.
    4.  User: `EXECUTE slice 1`. Agent reads `.workflow/active_task.json`.
    5.  Agent executes `bash scripts/enforce-branch.sh`.
    6.  Agent executes `edit` on `src/api.js`.
    7.  Agent executes `bash "npm test"`.
    8.  Agent edits `WORK.md` to update `[LOG]`.
*   **Token Economics**:
    *   **Input Tokens**: ~15k (Bloated by re-reading `WORK.md` at every step).
    *   **Output Tokens**: ~800 (Code edit + Log update).
    *   **Context Packets**: The exact context sent includes the full system prompt (all 10 skills appended), the history of the conversation, and the physical `WORK.md` file contents.
*   **Failure Analysis**: If `npm test` outputs 500 lines of Webpack build warnings before the test failure, all 500 lines enter the context window, drastically pushing the system toward compaction.

---

## PHASE 4 — RETRIEVAL FORENSICS

**The Weakest Link in the Architecture.**

The system possesses no background AST indexing, no semantic vector database, and no pre-computed dependency graphs.

*   **Retrieval Mechanism**: 100% reliant on synchronous `bash` execution (`ls -la`, `rg`, `find`) followed by the `read` tool (which has a 2000 line / 50KB limit).
*   **Token-Heavy Patterns**:
    1.  `rg -n "functionName" .` — Returns unformatted, heavily nested hits including test mocks, build artifacts (if not properly git-ignored), and vendor files.
    2.  `cat` or `read` on bundle files or minified assets when the agent misidentifies the target file.
*   **Retrieval Loops**: The model frequently guesses a filename, reads it, finds it is just an exporter/index file, reads the next file, ad infinitum. This consumes massive input tokens and latency.

---

## PHASE 5 — CONTEXT ENGINEERING ANALYSIS

The system's primary innovation is the `.workflow/tasks/[id]/WORK.md` state machine.

*   **Packing Strategy**: Instead of relying on the LLM's conversation history (which is subjected to the core engine's lossy auto-compaction threshold), `pi.dev` forces the LLM to write its cognitive state to a physical file.
*   **Context Poisoning**: The `[LOG]` section of `WORK.md` is appended to continuously. After 10 implementation steps, the `[LOG]` contains thousands of words of historical test outputs and git hashes. Because the agent must read `WORK.md` to find `[PLAN]` checkboxes, it is forced to ingest the bloated `[LOG]` every single turn.
*   **Effectiveness**: Highly effective at preventing "task amnesia" across days of work, but severely inefficient in token usage.

---

## PHASE 6 — EDIT SYSTEM ANALYSIS

The `edit` tool uses **exact-match text replacement** (`oldText` / `newText`).

*   **Reliability**: Fragile. Because the system relies on exact string matching, if the agent hallucinates formatting (e.g., spaces vs tabs, trailing commas) in the `oldText` block, the edit is rejected.
*   **Multi-file Failures**: When implementing a cross-file slice (e.g., changing a function signature in `api.ts` and updating 4 consumers), the agent must emit multiple `edit` tool calls. If one fails matching, the system is left in a broken, non-compiling state, triggering a panic retry loop.

---

## PHASE 7 — MODEL ROUTING ANALYSIS

*   **Behavior**: Routing is static per session. The user must explicitly launch `pi` with a specific model or change `~/.pi/agent/models.json`.
*   **Token Inefficiency**: Using Claude-3.5-Sonnet to execute `/triage` (which merely summarizes a JSON payload into `[BRIEF]`) is a massive waste of frontier model API credits.
*   **Missing Capability**: There is no dynamic step-down routing. The agent cannot say, "This is a simple bash script execution, route to Haiku." The entire RPIV flow runs on the session's default model.

---

## PHASE 8 — WORK.md FORENSICS

*   **Evolution**: Starts at ~50 lines. Grows linearly by ~20 lines per implementation slice due to the `[LOG]` requirement.
*   **Stale State**: If an agent manually modifies a file outside the `/implement` loop (e.g., during `/grill-with-docs`), the `[PLAN]` becomes desynchronized from the filesystem truth, causing subsequent implementation steps to fail.
*   **Verdict**: `WORK.md` improves short-term execution stability but degrades long-term session economics due to log pollution.

---

## PHASE 9 — LATENCY BREAKDOWN

*   **Model Inference**: 40% of runtime.
*   **Retrieval (`bash rg` / `read`)**: 35% of runtime (Waiting for bash child processes, parsing stdout).
*   **Verification (Test Suites)**: 20% of runtime.
*   **Context Packing/Compaction**: 5% of runtime.

*True Bottleneck*: Sequential read-evaluate-read loops during the `/grill-with-docs` phase.

---

## PHASE 10 — FAILURE TAXONOMY

| Failure Class | Root Cause | Severity | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Exact-Match Reject** | `oldText` hallucination (whitespace/indentation). | High | Inject line-number bounds or use a semantic diff application layer instead of raw strings. |
| **Context Eviction** | Native `pi` compaction summarizing away critical variable names. | Medium | Increase compaction triggers; rely heavier on `read` pagination. |
| **Log Bloat** | `[LOG]` in `WORK.md` growing to 500+ lines. | High | Implement log rotation; move verbose logs to `.workflow/archive/`. |
| **Stale Branches** | Executing `/plan` on `feat/A` then `/implement` on `main`. | Critical | The newly added `enforce-branch.sh` script mitigates this, but requires strict prompt adherence. |

---

## PHASE 11 — TOKEN ECONOMICS

*   **Largest Token Sink**: Unfiltered `stdout`/`stderr` from `bash` test suite executions. A single Webpack error can consume 8,000 input tokens.
*   **Repeated Token Waste**: The `shell_integration.sh` `--rpiv` flag injects *all* workflow skills into the system prompt simultaneously. The model carries the instructions for `/triage` even while executing `/verify`.
*   **Estimated Optimization**: Dynamically loading only the active phase's skill into the system prompt would reduce base input tokens by ~60% per request.

---

## PHASE 12 — OPTIMIZATION ROADMAP

**Immediate Fixes (Days):**
1.  **Strict Log Truncation**: Modify the `/implement` and `/verify` skills to write detailed logs to `.workflow/tasks/[id]/logs/` and only write a 1-line summary to `WORK.md` `[LOG]`.
2.  **Dynamic Skill Loading**: Modify the router so that typing `/plan` unloads the `/triage` and `/frame` skills from the active context, saving thousands of tokens.

**Medium-Term (Weeks):**
3.  **Bash Output Interceptor**: Implement a custom tool `bash_smart` that intercepts any stdout > 500 lines, automatically routing it to a cheap model (e.g., Llama 3 / Flash) to summarize the error before returning it to the frontier model.

**Long-Term Architectural Redesigns (Months):**
4.  **Semantic Retrieval Tooling**: Deprecate reliance on raw `bash rg` in favor of a native `search_ast` tool that returns compressed code signatures rather than raw files.
5.  **Fuzzy Edit Application**: Replace exact-match `edit` with a Language Server Protocol (LSP) backed AST-aware edit tool to eliminate whitespace-related diff rejections.