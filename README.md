# pi.dev

Personal workspace for advanced agentic coding workflows, specialized skills, and specialized mindsets.

## 🚀 R&D Agentic Workflow

This repository implements a high-performance "Staff Engineer" workflow for the Pi Coding Agent. Every task follows a disciplined lifecycle:

1.  **Investigate (`/investigate`)**: Phase 0 triage to find the root cause.
2.  **Frame (`/frame-problem`)**: Formalize the challenge in `PROBLEM.md`.
3.  **Language (`/ubiquitous-language`)**: Align domain naming and architecture.
4.  **Plan (`/write-a-plan`)**: TDD-first, vertical slice strategy in `PLAN.md`.
5.  **Implement (`/implement-plan`)**: Execute with adaptive quality gates and human-centric MRs.
6.  **Verify (`/verify-changes`)**: A holistic "Truth Test" (Code + Docs + System Zoom Out).

## 🧠 Mindsets (Hats)

Configured via `shell_integration.sh`:
- **Plan Hat (`--plan`)**: Loads the full R&D workflow suite.
- **Android Hat (`--android`)**: Specialized for KMP/Android development with quality gates.

## 📚 Terminology & Glossary

For a detailed breakdown of LLM metrics (Context, Caching, Tokens), see the [Agentic Terminology Guide](https://github.com/raquezha/.notes/blob/main/Glossary/Agentic%20Terminology.md).

## 🛠 Skills

Located in `pi/skills/`:
- `workflow/`: Core R&D skills.
- `android/`: Android-specific toolkits.
- `search/`: Brave Search integration.

## 🔌 Extensions

Located in `pi/extensions/`:
- `clean-repo/`: git cleanup helper
- `powerline-footer/`: footer styling
- `gemini-api/`: manual-only public Gemini API provider (`gemini-api/...`)

Run `./scripts/setup.sh` after cloning to symlink the default repo-local extensions into `~/.pi/agent/extensions/`.
Load `gemini-api` manually when you need it:

```bash
pi -e ./pi/extensions/gemini-api
```

Set `GEMINI_API_KEY` or `GOOGLE_API_KEY` in your shell rc (`~/.zshrc`, etc.) if you want Gemini models available in that session.

---
*Never Trust AI. Always Manual Review. Verify Every Change.*
