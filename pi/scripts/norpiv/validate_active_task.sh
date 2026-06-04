#!/usr/bin/env bash

# validate_active_task.sh
# Lightweight, print-only validation of .workflow/active_task.json and related files.

set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
ATF="$REPO_ROOT/.workflow/active_task.json"

if [[ ! -f "$ATF" ]]; then
  echo "ERROR: No active_task.json found at $ATF"
  exit 1
fi

echo "Active task file: $ATF"
jq '.' "$ATF" || true

TASK_PATH=$(jq -r '.taskPath // .path // empty' "$ATF")
TASK_SOURCE=$(jq -r '.source // empty' "$ATF")
TASK_ID=$(jq -r '.sourceId // .id // empty' "$ATF")
ACTIVE_TASK=$(jq -r '.active_task // empty' "$ATF")

echo
if [[ -n "$TASK_PATH" ]]; then
  if [[ "$TASK_PATH" = /* ]]; then
    WORK_MD="$TASK_PATH/WORK.md"
  else
    WORK_MD="$REPO_ROOT/$TASK_PATH/WORK.md"
  fi
  echo "Using taskPath -> checking: $WORK_MD"
  if [[ -f "$WORK_MD" ]]; then
    echo "OK: WORK.md exists at $WORK_MD"
  else
    echo "MISSING: WORK.md not found at $WORK_MD"
  fi
else
  echo "No taskPath in active_task.json; attempting to derive from source+id"
  if [[ -n "$TASK_ID" ]]; then
    if [[ -n "$TASK_SOURCE" ]]; then
      TASK_FOLDER="$TASK_SOURCE-$TASK_ID"
    else
      TASK_FOLDER="$TASK_ID"
    fi
    WORK_MD="$REPO_ROOT/.workflow/tasks/$TASK_FOLDER/WORK.md"
    echo "Derived path: $WORK_MD"
    if [[ -f "$WORK_MD" ]]; then
      echo "OK: WORK.md exists at $WORK_MD"
    else
      echo "MISSING: WORK.md not found at $WORK_MD"
    fi
  else
    echo "ERROR: Neither taskPath nor sourceId/id present in active_task.json"
  fi
fi

# If we located the task folder, check metadata.json consistency
if [[ -n "$WORK_MD" && -f "$WORK_MD" ]]; then
  TASK_DIR=$(dirname "$WORK_MD")
  META="$TASK_DIR/metadata.json"
  if [[ -f "$META" ]]; then
    echo "Found metadata.json: $META"
    jq '.' "$META" || true
    META_ID=$(jq -r '.id // empty' "$META")
    META_TF=$(jq -r '.taskFolder // empty' "$META")
    echo "metadata.id: $META_ID"
    echo "metadata.taskFolder: $META_TF"
    if [[ -n "$META_ID" && -n "$TASK_ID" && "$META_ID" != "$TASK_ID" ]]; then
      echo "WARN: metadata.id ($META_ID) differs from active_task.id ($TASK_ID)"
      echo "  This is expected if metadata.id stores the raw remote id and active_task uses a namespaced folder."
    fi
  else
    echo "MISSING: metadata.json not found at $META"
  fi
fi

# Print suggested fixes (print-only)
echo
echo "Suggested fixes (dry):"
if [[ -n "$WORK_MD" && ! -f "$WORK_MD" ]]; then
  echo "  - Re-run triage: ./pi/scripts/norpiv/triage_helper.sh <source> <id>"
  echo "  - Or update .workflow/active_task.json to include a correct taskPath or source+id"
fi

echo "Validation complete (print-only)."
