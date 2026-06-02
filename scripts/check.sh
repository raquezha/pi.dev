#!/usr/bin/env bash
# Lightweight repository quality gate for pi.dev.
# Does not inspect secrets or generated dependency trees.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

failures=0

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

info "Checking required commands"
check_command git
check_command bash
check_command jq
check_command python3

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

info "Checking shell scripts"
while IFS= read -r file; do
  if bash -n "$file"; then
    ok "$file"
  else
    fail "shell syntax failed: $file"
  fi
done < <(find scripts pi/scripts -type f -name '*.sh' 2>/dev/null | sort)

info "Checking skill frontmatter"
while IFS= read -r file; do
  if python3 - "$file" <<'PY'
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
  then
    ok "$file"
  else
    fail "invalid skill: $file"
  fi
done < <(find pi/skills -type f -name SKILL.md | sort)

info "Checking tracked scratch artifacts"
if [[ -e PLAN.md ]] && git ls-files --error-unmatch PLAN.md >/dev/null 2>&1; then
  fail "PLAN.md exists as a tracked scratch artifact; move durable content to docs/agents or .workflow/tasks"
else
  ok "no tracked PLAN.md scratch file in workspace"
fi

info "Checking active task pointer (if present)"
if [[ -f .workflow/active_task.json ]]; then
  if ./pi/scripts/workflow/validate_active_task.sh >/tmp/pi-dev-active-task-check.log 2>&1; then
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
