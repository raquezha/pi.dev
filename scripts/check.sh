#!/usr/bin/env bash
# Lightweight repository quality gate for pi.dev.
# Does not inspect secrets or generated dependency trees.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
NORPIV_DIR="${PI_NORPIV_DIR:-$REPO_ROOT/../nothing/packages/norpiv}"
cd "$REPO_ROOT"

failures=0
HAS_JQ=0

info() { echo "▸ $*"; }
ok() { echo "✅ $*"; }
warn() { echo "⚠️  $*"; }
fail() {
  failures=$((failures + 1))
  echo "❌ $*"
}

check_command() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd available"
  else
    fail "$cmd missing"
  fi
}

check_skill_frontmatter() {
  local file="$1"
  python3 - "$file" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()
if not text.startswith('---\n'):
    raise SystemExit('missing frontmatter fence')
try:
    _, fm, _body = text.split('---\n', 2)
except ValueError:
    raise SystemExit('malformed frontmatter')
name = re.search(r'^name:\s*([a-z0-9]+(?:-[a-z0-9]+)*)\s*$', fm, re.M)
desc = re.search(r'^description:\s*(.+)\s*$', fm, re.M)
if not name:
    raise SystemExit('missing or invalid name')
if not desc:
    raise SystemExit('missing description')
if name.group(1) != path.parent.name:
    raise SystemExit(f'name {name.group(1)!r} does not match directory {path.parent.name!r}')
PY
}

info "Checking required commands"
check_command git
check_command bash
if command -v jq >/dev/null 2>&1; then
  HAS_JQ=1
  ok "jq available"
else
  fail "jq missing"
fi
check_command python3

if [[ "$HAS_JQ" -eq 1 ]]; then
  info "Validating JSON"
  while IFS= read -r file; do
    if jq empty "$file" >/dev/null 2>&1; then
      ok "$file"
    else
      fail "invalid JSON: $file"
    fi
  done < <(find . -type f -name '*.json' \
    -not -path './node_modules/*' \
    -not -path './.git/*' \
    -not -path './.workflow/*' \
    -not -path './.secrets/*' \
    | sort)
else
  warn "Skipping JSON validation because jq is unavailable"
fi

info "Checking shell scripts"
while IFS= read -r file; do
  if bash -n "$file"; then
    ok "$file"
  else
    fail "shell syntax failed: $file"
  fi
done < <(
  {
    find scripts pi/scripts -type f -name '*.sh' 2>/dev/null
    if [[ -d "$NORPIV_DIR" ]]; then
      find "$NORPIV_DIR" -type f -name '*.sh' 2>/dev/null
    fi
  } | sort
)

info "Checking skill frontmatter"
while IFS= read -r file; do
  if check_skill_frontmatter "$file"; then
    ok "$file"
  else
    fail "invalid skill: $file"
  fi
done < <(
  {
    find pi/skills -type f -name SKILL.md
    if [[ -d "$NORPIV_DIR" ]]; then
      find "$NORPIV_DIR" -type f -name SKILL.md
    fi
  } | sort
)

info "Checking tracked scratch artifacts"
if [[ -e PLAN.md ]] && git ls-files --error-unmatch PLAN.md >/dev/null 2>&1; then
  fail "PLAN.md exists as a tracked scratch artifact; move durable content to docs/agents or .workflow/tasks"
else
  ok "no tracked PLAN.md scratch file in workspace"
fi

ACTIVE_TASK_VALIDATOR="./pi/scripts/workflow/validate_active_task.sh"
if [[ -x "$NORPIV_DIR/scripts/validate_active_task.sh" ]]; then
  ACTIVE_TASK_VALIDATOR="$NORPIV_DIR/scripts/validate_active_task.sh"
fi

info "Checking active task pointer (if present)"
if [[ -f .workflow/active_task.json ]]; then
  if [[ "$HAS_JQ" -eq 0 ]]; then
    warn "Skipping active task validation because jq is unavailable"
  elif "$ACTIVE_TASK_VALIDATOR" >/tmp/pi-dev-active-task-check.log 2>&1; then
    ok ".workflow/active_task.json"
  else
    warn "active task validation reported issues (see /tmp/pi-dev-active-task-check.log)"
  fi
else
  ok "no active task pointer"
fi

if [[ "$failures" -gt 0 ]]; then
  echo
  fail "$failures check(s) failed"
  exit 1
fi

echo
ok "All checks passed"
