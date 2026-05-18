#!/bin/bash

# Triage Helper: Manages namespaced task workspaces
# Usage: ./triage_helper.sh [source] [id]

SOURCE=$1
ID=$2
BASE_DIR=".workflow/tasks"

if [ -z "$SOURCE" ] || [ -z "$ID" ]; then
    echo "Usage: ./triage_helper.sh [github|gitlab|jira|local] [id]"
    exit 1
fi

# 1. Sanitize local ID if generic (case-insensitive check)
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
ID_LOWER=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
if [ "$SOURCE" == "local" ] && [[ "$ID_LOWER" =~ ^(problem|task|issue|work|todo)$ ]]; then
    ID=$(echo "$BRANCH_NAME" | sed 's/[^a-zA-Z0-9]/-/g')
    echo "Generic local ID detected. Falling back to branch-derived name '$ID'..."
fi

# Construct the canonical task folder name and path
TASK_FOLDER="$SOURCE-$ID"
TASK_DIR="$BASE_DIR/$TASK_FOLDER"
mkdir -p "$TASK_DIR"

echo "Initializing workspace in $TASK_DIR..."

case $SOURCE in
    github)
        echo "Fetching GitHub Issue #$ID..."
        gh issue view "$ID" --json title,body,author,labels,comments > "$TASK_DIR/metadata.json"
        echo "# WORK: GitHub #$ID" > "$TASK_DIR/WORK.md"
        gh issue view "$ID" >> "$TASK_DIR/WORK.md"
        ;;
    gitlab)
        echo "Fetching GitLab Issue #$ID..."
        glab issue view "$ID" > "$TASK_DIR/WORK.md"
        echo "{\"id\": \"$ID\", \"source\": \"gitlab\"}" > "$TASK_DIR/metadata.json"
        ;;
    jira)
        echo "Fetching Jira Ticket $ID..."
        jira issue view "$ID" > "$TASK_DIR/WORK.md"
        jira issue view "$ID" --raw > "$TASK_DIR/metadata.json"
        ;;
    local)
        echo "Initializing local task workspace: $ID..."
        echo "# WORK: Local Task $ID" > "$TASK_DIR/WORK.md"
        echo "{\"id\": \"$ID\", \"source\": \"local\"}" > "$TASK_DIR/metadata.json"
        ;;
    *)
        echo "Unknown source: $SOURCE"
        exit 1
        ;;
esac

# Append branch info to metadata.json (universal)
# We use python3 if available for simple json manipulation, or just overwrite/append if we don't mind.
# Since we just created metadata.json, let's just use a temporary file and jq if available, or simple python.
if command -v jq >/dev/null 2>&1; then
    jq --arg branch "$BRANCH_NAME" '. + {branch: $branch}' "$TASK_DIR/metadata.json" > "$TASK_DIR/metadata.json.tmp" && mv "$TASK_DIR/metadata.json.tmp" "$TASK_DIR/metadata.json"
    # Also record the task folder name for clarity
    jq --arg tf "$TASK_FOLDER" '. + {taskFolder: $tf}' "$TASK_DIR/metadata.json" > "$TASK_DIR/metadata.json.tmp" && mv "$TASK_DIR/metadata.json.tmp" "$TASK_DIR/metadata.json"
else
    # Fallback to simple python
    python3 - <<PY
import json,sys
p=sys.argv[1]
branch=sys.argv[2]
tf=sys.argv[3]
d=json.load(open(p))
d['branch']=branch
d['taskFolder']=tf
json.dump(d,open(p,'w'))
PY
    "$TASK_DIR/metadata.json" "$BRANCH_NAME" "$TASK_FOLDER"
fi

# Append mandatory sections for RPIV workflow
echo -e "\n## [BRIEF]\n- \n\n## [PLAN]\n- [ ] \n\n## [LOG]\n- $(date +"%Y-%m-%d %I:%M %p"): Task initialized via /triage" >> "$TASK_DIR/WORK.md"

# Append META to WORK.md if not already present with branch info
if ! grep -q "\[META\]" "$TASK_DIR/WORK.md"; then
    echo -e "\n[META]\nBranch: $BRANCH_NAME" >> "$TASK_DIR/WORK.md"
fi

# Create the Pointer for the Agent (canonical shape)
# Keep metadata.id as the raw ID (per repo conventions)
cat > ".workflow/active_task.json" <<JSON
{"active_task": "$TASK_FOLDER", "source": "$SOURCE", "id": "$ID", "sourceId": "$ID", "taskPath": "$TASK_DIR", "path": "$TASK_DIR", "branch": "$BRANCH_NAME"}
JSON

echo "Triage complete. Single-file WORK.md ready at $TASK_DIR."
