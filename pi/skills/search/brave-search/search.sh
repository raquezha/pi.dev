#!/usr/bin/env bash

# Check for API key
if [ -z "$BRAVE_SEARCH_API_KEY" ]; then
  echo "Error: BRAVE_SEARCH_API_KEY environment variable is not set."
  echo "Please add it to your ~/.pi-secrets/.env file."
  exit 1
fi

QUERY="$1"
if [ -z "$QUERY" ]; then
  echo "Usage: ./search.sh \"query\" [--summarize]"
  exit 1
fi

SUMMARIZE=false
if [ "$2" == "--summarize" ]; then
  SUMMARIZE=true
fi

# Brave Search API endpoint
ENDPOINT="https://api.search.brave.com/res/v1/web/search"

# Perform search
# Note: We use -H "Accept-Encoding: gzip" and pipe to gunzip because Brave API recommends it,
# but for simplicity in a script, let's see if we can just get plain JSON.
# Actually, the API supports plain JSON if we don't ask for gzip.

if [ "$SUMMARIZE" = true ]; then
  # If summarizing, we might want to use the 'summary' parameter if available, 
  # but standard web search returns snippets.
  # Brave also has a 'summarizer' endpoint, but let's stick to web search for now.
  RESPONSE=$(curl -s -G "$ENDPOINT" \
    --data-urlencode "q=$QUERY" \
    -H "Accept: application/json" \
    -H "X-Subscription-Token: $BRAVE_SEARCH_API_KEY")
else
  RESPONSE=$(curl -s -G "$ENDPOINT" \
    --data-urlencode "q=$QUERY" \
    -H "Accept: application/json" \
    -H "X-Subscription-Token: $BRAVE_SEARCH_API_KEY")
fi

# Check for errors in response
if echo "$RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
  echo "API Error: $(echo "$RESPONSE" | jq -r '.message')"
  exit 1
fi

# Output results in a readable format for the agent
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

