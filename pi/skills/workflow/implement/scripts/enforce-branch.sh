#!/usr/bin/env bash

# enforce-branch.sh
# Verifies the active branch before implementation.
# Prevents working on main/master and ensures alignment with task metadata.

set -euo pipefail

# Find repo root to ensure paths are absolute and reliable
REPO_ROOT=$(git rev-parse --show-toplevel)
ACTIVE_TASK_FILE="$REPO_ROOT/.workflow/active_task.json"

if [[ ! -f "$ACTIVE_TASK_FILE" ]]; then
    echo "ERROR: No active task found at $ACTIVE_TASK_FILE."
    echo "Please run /triage [source]:[id] first."
    exit 1
fi

TASK_SOURCE=$(jq -r '.source // empty' "$ACTIVE_TASK_FILE")
TASK_ID=$(jq -r '.sourceId // .id // empty' "$ACTIVE_TASK_FILE")
TASK_PATH=$(jq -r '.taskPath // .path // empty' "$ACTIVE_TASK_FILE")

# If ID is missing but TASK_PATH exists, try to derive info
if [[ -z "$TASK_ID" && -n "$TASK_PATH" ]]; then
    echo "WARNING: 'sourceId' missing in active_task.json. Attempting to use 'taskPath'."
    # Use absolute TASK_PATH if it's absolute, otherwise relative to REPO_ROOT
    if [[ "$TASK_PATH" = /* ]]; then
        WORK_MD="$TASK_PATH/WORK.md"
    else
        WORK_MD="$REPO_ROOT/$TASK_PATH/WORK.md"
    fi
else
    WORK_MD="$REPO_ROOT/.workflow/tasks/${TASK_SOURCE}-${TASK_ID}/WORK.md"
fi

if [[ ! -f "$WORK_MD" ]]; then
    echo "ERROR: WORK.md not found at $WORK_MD."
    echo "Check if the task was initialized correctly with /triage."
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
