# zerolang – A Native Systems Language for Agents

**Summary:**
- Zero is a native, agent-oriented programming language.
- It is **compiled** (needs a CLI tool), not interpreted. You install it from https://zerolang.ai.
- Main design goals: explicit effects, predictable memory, structured JSON outputs, and toolchain transparency—ideal for LLM/agent harnessing or automation.
- All CLI tools emit JSON (if you want), easy to consume from scripts or other agents.

**Installation:**
```
curl -fsSL https://zerolang.ai/install.sh | bash
export PATH="$HOME/.zero/bin:$PATH"
zero --version
```

**Hello World in Zero:**
```zero
fn main() {
  print("Hello, world!")
}
```

**Agentic Strengths:**
- No 'magic' globals, no implicit state.
- Strict typing, explicit outputs—agents know exactly what to expect.
- Compiles down to small native binaries (think Go-level DX, not Python scripting).

**Use when:**
- You need reproducible, audit-friendly automation.
- Agent/LLM frameworks need to chain, check, or mutate codebases reliably.

(See https://github.com/vercel-labs/zero for examples)
