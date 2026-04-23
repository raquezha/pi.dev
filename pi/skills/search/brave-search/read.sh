#!/usr/bin/env bash

URL="$1"
if [ -z "$URL" ]; then
  echo "Usage: ./read.sh <url>"
  exit 1
fi

# We use r.jina.ai to get a clean markdown version of the page.
# This is a common and effective way for AI agents to "read" web pages.
curl -s "https://r.jina.ai/$URL"
