#!/usr/bin/env bash
# Print-only health report for pi.dev local setup.
# This script intentionally does not read secret files or print secret values.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PI_DIR="$REPO_ROOT/pi"
AGENT_DIR="$HOME/.pi/agent"
CURRENT_BRANCH="$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || true)"

info() { echo "▸ $*"; }
ok() { echo "✅ $*"; }
warn() { echo "⚠️  $*"; }
err() { echo "❌ $*"; }

exists_report() {
  local label="$1"
  local path="$2"
  if [[ -e "$path" ]]; then ok "$label: $path"; else warn "$label missing: $path"; fi
}

link_report() {
  local label="$1"
  local expected="$2"
  local actual="$3"

  if [[ ! -e "$actual" && ! -L "$actual" ]]; then
    warn "$label not linked: $actual"
    return
  fi
  if [[ ! -L "$actual" ]]; then
    warn "$label exists but is not a symlink: $actual"
    return
  fi

  local target
  target="$(readlink "$actual")"
  if [[ "$target" == "$expected" ]]; then
    ok "$label linked"
  else
    warn "$label points to $target (expected $expected)"
  fi
}

cmd_report() {
  local cmd="$1"
  local purpose="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd available ($purpose)"
  else
    warn "$cmd missing ($purpose)"
  fi
}

json_report() {
  local label="$1"
  local file="$2"
  if [[ ! -f "$file" ]]; then
    warn "$label missing: $file"
  elif jq empty "$file" >/dev/null 2>&1; then
    ok "$label valid JSON"
  else
    err "$label invalid JSON: $file"
  fi
}

echo ""
echo "pi.dev doctor"
echo "============="
echo "repo:   $REPO_ROOT"
echo "branch: ${CURRENT_BRANCH:-<none>}"
echo "agent:  $AGENT_DIR"
echo ""

info "Core files"
exists_report "AGENTS.md" "$REPO_ROOT/AGENTS.md"
exists_report "CONTEXT.md" "$REPO_ROOT/CONTEXT.md"
exists_report "pi/AGENTS.md" "$PI_DIR/AGENTS.md"
json_report "models.json" "$PI_DIR/models.json"
json_report "settings.json" "$PI_DIR/settings.json"

info "Command line tools"
cmd_report pi "agent runtime"
cmd_report jq "JSON checks and setup merges"
cmd_report gh "GitHub issue/PR workflows"
cmd_report glab "GitLab issue/MR workflows"
cmd_report acli "Jira sync workflows"
cmd_report tmux "optional search worker/multitasking"

info "Linked defaults"
link_report "models.json" "$PI_DIR/models.json" "$AGENT_DIR/models.json"
link_report "keybindings.json" "$PI_DIR/keybindings.json" "$AGENT_DIR/keybindings.json"
link_report "powerline-footer" "$PI_DIR/extensions/powerline-footer" "$AGENT_DIR/extensions/powerline-footer"
link_report "env-protection" "$PI_DIR/extensions/env-protection" "$AGENT_DIR/extensions/env-protection"
link_report "search-subagent" "$PI_DIR/extensions/search-subagent" "$AGENT_DIR/extensions/search-subagent"
link_report "search skills" "$PI_DIR/skills/search" "$AGENT_DIR/skills/search"
link_report "cleanup skill" "$PI_DIR/skills/workflow/cleanup" "$AGENT_DIR/skills/cleanup"

info "Workflow state"
if [[ -f "$REPO_ROOT/.workflow/active_task.json" ]]; then
  json_report "active_task.json" "$REPO_ROOT/.workflow/active_task.json"
  "$PI_DIR/scripts/workflow/validate_active_task.sh" || true
else
  ok "no active task pointer"
fi

info "Git cleanliness"
if git -C "$REPO_ROOT" diff --quiet -- . ':(exclude).workflow'; then
  ok "working tree has no unstaged tracked changes"
else
  warn "working tree has local modifications"
  git -C "$REPO_ROOT" status --short
fi

info "Secrets"
warn "secret files are intentionally not inspected by doctor"

echo ""
ok "doctor complete"
