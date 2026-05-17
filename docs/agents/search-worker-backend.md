# Search Worker Backend

## Purpose
Provide a skill-scoped execution backend for `pi/skills/search/` so Brave Search and Firecrawl can run search tasks through a shared worker wrapper.
The launcher loads only the required allowlisted env vars from the current shell or `~/.pi-secrets/.env`, exports them, and never prints secret values.

## Scope
- In: `brave-search`, `firecrawl` (search/read/map/scrape entrypoints)
- Out: global agent execution, non-search skills

## Modes
- `auto` (default): use tmux when available, otherwise run inline
- `tmux`: require tmux
- `inline`: always run inline
- `strict`: fail if tmux is missing

## Result contract
The worker preserves normal stdout/stderr and exit codes from the wrapped skill command.
If required env is missing, the launcher fails fast with only variable names, not values.

## Implementation
- Shared helper: `pi/skills/search/_worker.sh`
- Entry points re-enter with `--worker-entry`
- `tmux` is optional and only used when available or required by mode
- The launcher exports only the required vars before backend spawn

## Setup
`./scripts/setup.sh` already checks for tmux and now calls it out as recommended for the search worker backend.
