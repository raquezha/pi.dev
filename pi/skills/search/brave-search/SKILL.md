---
name: brave-search
description: Search the web using Brave Search API. Use this skill when you need to find information, documentation, or answers that are not in the local codebase.
---

# Brave Search Skill

This skill provides web search capabilities using the Brave Search API.

## Prerequisites

- [Brave Search API Key](https://api.search.brave.com/app/dashboard)
- `BRAVE_SEARCH_API_KEY` environment variable set in `~/.pi-secrets/.env`
- `jq` installed for JSON processing

## Usage

The agent can use the following commands to search the web. The results include web pages, infoboxes (summaries), and FAQs.

### Search Web
```bash
./search.sh "your search query"
```

### Search and Get Summaries
```bash
./search.sh "your search query" --summarize
```

## Implementation

The skill uses a helper script `search.sh` to interact with the API.
