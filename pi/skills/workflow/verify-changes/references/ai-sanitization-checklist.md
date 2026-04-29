# AI-Sanitization Checklist

Use this checklist to catch common AI agent "tells" and mistakes.

### 1. Hallucinations
- [ ] **Fake Libraries**: Did the AI "invent" a library or an extension method that doesn't exist?
- [ ] **Ghost Methods**: Are there any new private methods that are defined but never called?

### 2. Laziness & Placeholders
- [ ] **The "Lazy TODO"**: Find any `// TODO:`, `// FIXME:`, or `// Implement later`. These must be resolved or explicitly flagged.
- [ ] **The Boilerplate Comment**: Remove comments that explain the obvious (e.g., `// This is the constructor`, `// Get the user name`).

### 3. Verbosity & Noise
- [ ] **Extra Logs**: Remove `println`, `Log.d`, or `console.log` statements used during debugging.
- [ ] **Duplicate Logic**: Ensure the AI didn't rewrite an existing utility function under a new name.

### 4. Project Integrity
- [ ] **Unused Imports**: Always remove them.
- [ ] **Platform Leakage (KMP)**: Ensure no platform-specific imports (like `android.os.*`) leaked into `commonMain`.
- [ ] **Resource Alignment**: Ensure hardcoded strings are moved to `strings.xml` or equivalent if required by the project.
