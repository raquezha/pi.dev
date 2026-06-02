# Search Subagent

Delegates Brave Search and Firecrawl work outside the main model context.

- `search_subagent` defaults to fast direct script/API mode: no child `pi`, no tmux
- direct mode forces `SEARCH_WORKER_MODE=inline` so search scripts do not spawn tmux
- optional child-pi mode is available with `SEARCH_SUBAGENT_MODE=child-pi`
- child-pi mode loads only the relevant search skill and still forces inline search workers
- the main session receives a compact result back
- `/search-subagent.smoke` runs a deterministic child-pi sanity check and reports: `Yes, my lord. I'm here to serve.`
- live progress updates render while the child process is running
- `limit` is validated to `1-20`
- Firecrawl scrape/map URLs must be valid `http(s)` URLs
- direct output is truncated to `SEARCH_SUBAGENT_MAX_OUTPUT_CHARS` when needed; default `12000`
- raw child/direct stdout/stderr is omitted from tool details unless `SEARCH_SUBAGENT_DEBUG=1`
