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

TASK_DIR="$BASE_DIR/$SOURCE-$ID"
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
        echo "Branch: $(git rev-parse --abbrev-ref HEAD)" >> "$TASK_DIR/WORK.md"
        echo "{\"id\": \"$ID\", \"source\": \"local\"}" > "$TASK_DIR/metadata.json"
        ;;
    *)
        echo "Unknown source: $SOURCE"
        exit 1
        ;;
esac

# Create the Pointer for the Agent
echo "{\"active_task\": \"$SOURCE-$ID\", \"path\": \"$TASK_DIR\", \"source\": \"$SOURCE\"}" > ".workflow/active_task.json"

echo "Triage complete. Single-file WORK.md ready at $TASK_DIR."
