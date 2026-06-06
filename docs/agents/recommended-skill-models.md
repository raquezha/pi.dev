# Recommended Models by Skill

Use this cheat sheet when choosing a model for pi.dev skills.

## Routing rules

1. Explicit user choice wins: `--model` / `--provider` always overrides auto-routing.
2. Skill routing applies when pi is launched with a skill or hat, such as `pi --dev`, `pi --rpiv`, or `pi --skill <path>`.
3. If the suggested model is unavailable, keep the current selected model.
4. Live in-session skill activation does not auto-switch yet; switch manually if needed.

## Model tiers

| Provider | Model | Use for |
|---|---|---|
| `openai-codex` | `gpt-5.5` | Hard coding, deep reasoning, migrations, multi-file changes |
| `openai-codex` | `gpt-5.4` | Skill design, documentation reasoning, medium-complexity work |
| `github-copilot` | `gpt-4.1` | Daily driver, planning, search summaries, normal workflow |
| `github-copilot` | `gpt-5-mini` | Fast routine tasks, cleanup, triage, verification, sync |

## Skill recommendations

| Skill | Provider | Model | Description |
|---|---|---|---|
| chatting / quick Q&A | `github-copilot` | `gpt-4.1` | Default simple chat and small asks |
| cleanup | `github-copilot` | `gpt-5-mini` | Fast repo hygiene and deletes |
| triage | `github-copilot` | `gpt-5-mini` | Task intake and workspace setup |
| frame | `github-copilot` | `gpt-4.1` | Turn task data into a brief |
| plan | `github-copilot` | `gpt-4.1` | Draft thin implementation slices |
| verify | `github-copilot` | `gpt-5-mini` | Run checks and validate results |
| sync | `github-copilot` | `gpt-5-mini` | Update tracker/state |
| change-review | `github-copilot` | `gpt-5-mini` | Review local diffs, GitHub PRs, and GitLab MRs |
| ci-triage | `github-copilot` | `gpt-5-mini` | Triage GitHub Actions, GitLab CI, and local gate failures |
| update-docs | `openai-codex` | `gpt-5.4` | Durable docs and workflow notes |
| agent-os | `github-copilot` | `gpt-4.1` | Seed or sync repo agent context |
| brave-search | `github-copilot` | `gpt-4.1` | Search and summarize web findings |
| firecrawl | `github-copilot` | `gpt-4.1` | Extract, map, and search pages |
| implement | `openai-codex` | `gpt-5.5` | Code changes, refactors, and execution |
| grill-with-docs | `openai-codex` | `gpt-5.5` | Deep doc/code analysis before planning |
| pi-skill-creator | `openai-codex` | `gpt-5.4` | Skill design, structure, and authoring |
| android-adb | `github-copilot` | `gpt-4.1` | Device commands and basic debugging |
| android-gradle | `github-copilot` | `gpt-4.1` | Builds, tests, and Gradle ops |
| android-project-setup | `github-copilot` | `gpt-4.1` | New project/module setup |
| android-compose | `openai-codex` | `gpt-5.5` | Compose UI work and refactors |
| android-logcat-smart | `openai-codex` | `gpt-5.5` | Crash and stacktrace analysis |
| android-agp9-migration | `openai-codex` | `gpt-5.5` | AGP migration and complex build changes |
| android-ci-component-adoption | `openai-codex` | `gpt-5.5` | CI adoption, drift repair, and multi-file updates |

## Model-router doctor idea

A model-router doctor would be a print-only diagnostic that explains why pi selected a provider/model for a session: explicit CLI override, hat-loaded skill priority, fallback because a provider/model is unavailable, or current-model retention. It is useful when auto-routing feels surprising. This repo currently documents routing in this file and implements hat routing in `pi/shell_integration.sh`; a dedicated command can be added later if routing needs more debugging.

## Quick examples

```bash
# Auto-selects a model from the dev skill bundle.
pi --dev

# Auto-selects the firecrawl recommendation.
pi --skill ~/Developer/pi.dev/pi/skills/search/firecrawl

# Explicit model override wins.
pi --model openai-codex/gpt-5.5 --skill ~/RQZ/personal/nothing/packages/norpiv/cleanup
```
