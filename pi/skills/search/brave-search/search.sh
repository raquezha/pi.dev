#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/../_worker.sh"

SEARCH_WORKER_REQUIRED_ENV="BRAVE_SEARCH_API_KEY"

usage() {
  cat <<'EOF'
Usage: ./search.sh <query> [--summarize] [--table] [--limit <n>]
EOF
}

brave_search_main() {
  QUERY="${1:-}"
  if [[ -z "$QUERY" ]]; then
    usage
    exit 1
  fi

  shift || true

  SUMMARIZE=false
  TABLE=false
  LIMIT=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --summarize) SUMMARIZE=true ;;
      --table) TABLE=true ;;
      --limit)
        [[ $# -ge 2 ]] || search_worker_error "--limit requires a value."
        LIMIT="$2"
        shift
        ;;
      *) search_worker_error "Unknown flag: $1" ;;
    esac
    shift
  done

  if [[ -n "$LIMIT" && ! "$LIMIT" =~ ^[0-9]+$ ]]; then
    search_worker_error "--limit expects a non-negative integer."
  fi

  if [[ -z "${BRAVE_SEARCH_API_KEY:-}" ]]; then
    search_worker_error "BRAVE_SEARCH_API_KEY is unavailable after launcher bootstrap."
    exit 1
  fi

  ENDPOINT="https://api.search.brave.com/res/v1/web/search"

  RESPONSE=$(curl -s -G "$ENDPOINT" \
    --data-urlencode "q=$QUERY" \
    -H "Accept: application/json" \
    -H "X-Subscription-Token: $BRAVE_SEARCH_API_KEY")

  if echo "$RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    echo "API Error: $(echo "$RESPONSE" | jq -r '.message')"
    exit 1
  fi

  if [[ "$TABLE" == true ]]; then
    printf '| Rank | Title | URL | Description |\n|---:|---|---|---|\n'
    rank=1
    while IFS=$'\t' read -r title url description; do
      title="${title//$'\n'/ }"
      description="${description//$'\n'/ }"
      title="${title//|/\\|}"
      description="${description//|/\\|}"
      printf '| %s | %s | %s | %s |\n' "$rank" "$title" "$url" "$description"
      rank=$((rank + 1))
    done < <(echo "$RESPONSE" | jq -r --arg limit "$LIMIT" '
      (.web.results // [])
      | to_entries[]
      | select(($limit == "") or (.key + 1) <= ($limit | tonumber))
      | .value
      | [(.title // ""), (.url // ""), (.description // "")] | @tsv
    ')
    exit 0
  fi

  echo "--- RESULTS FOR: $QUERY ---"

  INFOBOX=$(echo "$RESPONSE" | jq -r '.infobox // empty')
  if [[ -n "$INFOBOX" ]]; then
    echo "### INFOBOX ###"
    echo "$RESPONSE" | jq -r '.infobox.content.title + ": " + .infobox.content.description'
    echo "---"
  fi

  FAQ=$(echo "$RESPONSE" | jq -r '.faq.results // empty')
  if [[ -n "$FAQ" ]]; then
    echo "### FAQ ###"
    echo "$RESPONSE" | jq -r '.faq.results[] | "Q: " + .question + "\nA: " + .answer + "\n---"'
  fi

  echo "### WEB RESULTS ###"
  echo "$RESPONSE" | jq -r --arg limit "$LIMIT" '
    (.web.results // [])
    | to_entries[]
    | select(($limit == "") or (.key + 1) <= ($limit | tonumber))
    | .value
    | "Title: " + .title + "\nURL: " + .url + "\nDescription: " + .description + "\n---"
  '
}

if [[ "${1:-}" == "--worker-entry" ]]; then
  shift
  brave_search_main "$@"
  exit $?
fi

search_worker_run "$0" "$@"
