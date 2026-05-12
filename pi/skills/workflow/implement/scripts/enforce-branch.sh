#!/usr/bin/env bash

# enforce-branch.sh
# Verifies the active branch before implementation.
# Prevents working on main/master and ensures alignment with task metadata.

set -euo pipefail

ACTIVE_TASK_FILE=".workflow/active_task.json"

if [[ ! -f "$ACTIVE_TASK_FILE" ]]; then
    echo "ERROR: No active task found at $ACTIVE_TASK_FILE."
    echo "Please run /triage first."
    exit 1
fi

TASK_SOURCE=$(jq -r '.source' "$ACTIVE_TASK_FILE")
TASK_ID=$(jq -r '.id' "$ACTIVE_TASK_FILE")
TASK_DIR=".workflow/tasks/${TASK_SOURCE}-${TASK_ID}"
WORK_MD="$TASK_DIR/WORK.md"

if [[ ! -f "$WORK_MD" ]]; then
    echo "ERROR: WORK.md not found at $WORK_MD."
    exit 1
fi

CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Check if we are on a protected branch
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
    echo "WARNING: Currently on protected branch '$CURRENT_BRANCH'."
    
    # Generate a safe task branch name
    # Sanitize the task ID for branch naming (replace spaces/special chars with hyphens)
    CLEAN_ID=$(echo "$TASK_ID" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//;s/-$//')
    NEW_BRANCH="feat/${TASK_SOURCE}-${CLEAN_ID}"
    
    echo "ACTION: Creating and switching to task branch: $NEW_BRANCH"
    git checkout -b "$NEW_BRANCH"
    echo "SUCCESS: Branch switched to $NEW_BRANCH."
    echo "AGENT_INSTRUCTION: Update [META] in WORK.md to record 'Branch: $NEW_BRANCH'."
    exit 0
fi

echo "Branch is not protected. Safe to proceed."
echo "AGENT_INSTRUCTION: Ensure $CURRENT_BRANCH is recorded in [META] of WORK.md."
exit 0
