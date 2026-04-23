#!/usr/bin/env bash

# Check for API key
if [ -z "$BRAVE_SEARCH_API_KEY" ]; then
  echo "Error: BRAVE_SEARCH_API_KEY environment variable is not set."
  echo "Please add it to your ~/.pi-secrets/.env file."
  exit 1
fi

QUERY="$1"
if [ -z "$QUERY" ]; then
  echo "Usage: ./search.sh \"query\" [--summarize] [--table]"
  exit 1
fi

# Flags
shift || true
SUMMARIZE=false
TABLE=false
for arg in "$@"; do
  case "$arg" in
    --summarize) SUMMARIZE=true ;;
    --table) TABLE=true ;;
  esac
done

# Brave Search API endpoint
ENDPOINT="https://api.search.brave.com/res/v1/web/search"

# Perform search
RESPONSE=$(curl -s -G "$ENDPOINT" \
  --data-urlencode "q=$QUERY" \
  -H "Accept: application/json" \
  -H "X-Subscription-Token: $BRAVE_SEARCH_API_KEY")

# Check for errors in response
if echo "$RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
  echo "API Error: $(echo "$RESPONSE" | jq -r '.message')"
  exit 1
fi

# If table output requested, render Markdown table of web results
if [ "$TABLE" = true ]; then
  echo "$RESPONSE" | jq -r '
    if .web and .web.results then
      .web.results | to_entries | ( ["| Rank | Title | URL | Description |","|---:|---|---|---:|"] ), ( .[] | "| " + ((.key+1)|tostring) + " | " + (.value.title // "") | gsub("\n"; " ") | gsub("\|"; "\\|") + " | " + (.value.url // "") + " | " + ((.value.description // "") | gsub("\n"; " ") | gsub("\|"; "\\|")) + " |" )
    else
      "No web.results in response"
    end
  '
  exit 0
fi

# Default human-readable output
echo "--- RESULTS FOR: $QUERY ---"

# Check for Infobox
INFOBOX=$(echo "$RESPONSE" | jq -r '.infobox // empty')
if [ -n "$INFOBOX" ]; then
  echo "### INFOBOX ###"
  echo "$RESPONSE" | jq -r '.infobox.content.title + ": " + .infobox.content.description'
  echo "---"
fi

# Check for FAQ
FAQ=$(echo "$RESPONSE" | jq -r '.faq.results // empty')
if [ -n "$FAQ" ]; then
  echo "### FAQ ###"
  echo "$RESPONSE" | jq -r '.faq.results[] | "Q: " + .question + "\nA: " + .answer + "\n---"'
fi

# Web Results
echo "### WEB RESULTS ###"
echo "$RESPONSE" | jq -r '
  .web.results[] | 
  "Title: " + .title + "\nURL: " + .url + "\nDescription: " + .description + "\n---"
'

