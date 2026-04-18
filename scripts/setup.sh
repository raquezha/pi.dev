#!/usr/bin/env bash
#
# setup.sh — connect pi.dev repo to ~/.pi/agent/
#
# Usage:
#   git clone https://github.com/raquezha/pi.dev ~/Developer/pi.dev
#   cd ~/Developer/pi.dev
#   ./scripts/setup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PI_DIR="$REPO_DIR/pi"
AGENT_DIR="$HOME/.pi/agent"
SECRETS_FILE="$HOME/.pi-secrets/.env"

# ── Colors ────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${CYAN}▸${NC} $1"; }
ok()    { echo -e "${GREEN}✅${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠️${NC}  $1"; }
err()   { echo -e "${RED}❌${NC} $1"; }

echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    pi.dev → ~/.pi/agent setup        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
echo ""

# ── Preflight checks ─────────────────────────────────────────────────

if ! command -v pi &>/dev/null; then
  err "pi is not installed. Run: npm install -g @mariozechner/pi-coding-agent"
  exit 1
fi

if [[ ! -d "$PI_DIR" ]]; then
  err "pi/ directory not found in repo. Are you in the right directory?"
  exit 1
fi

# ── Ensure directories exist ─────────────────────────────────────────

mkdir -p "$AGENT_DIR/extensions"
mkdir -p "$AGENT_DIR/skills"
mkdir -p "$AGENT_DIR/prompts"
mkdir -p "$AGENT_DIR/themes"
mkdir -p "$HOME/.pi-secrets"

# ── Symlink helper ────────────────────────────────────────────────────

link_file() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [[ ! -e "$src" ]]; then
    warn "Skipping $label (source not found: $src)"
    return
  fi

  if [[ -L "$dest" ]]; then
    local current_target
    current_target="$(readlink "$dest")"
    if [[ "$current_target" == "$src" ]]; then
      ok "$label (already linked)"
      return
    fi
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    local backup="$dest.backup.$(date +%s)"
    mv "$dest" "$backup"
    warn "Backed up existing $label → $(basename "$backup")"
  fi

  ln -s "$src" "$dest"
  ok "Linked $label"
}

link_dir() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [[ ! -d "$src" ]]; then
    warn "Skipping $label (source not found)"
    return
  fi

  if [[ -L "$dest" ]]; then
    local current_target
    current_target="$(readlink "$dest")"
    if [[ "$current_target" == "$src" ]]; then
      ok "$label (already linked)"
      return
    fi
    rm "$dest"
  elif [[ -d "$dest" ]]; then
    local backup="$dest.backup.$(date +%s)"
    mv "$dest" "$backup"
    warn "Backed up existing $label → $(basename "$backup")"
  fi

  ln -s "$src" "$dest"
  ok "Linked $label"
}

# ── Link config files ────────────────────────────────────────────────

echo ""
info "Linking config files..."
echo ""

link_file "$PI_DIR/settings.json"   "$AGENT_DIR/settings.json"   "settings.json"
link_file "$PI_DIR/models.json"     "$AGENT_DIR/models.json"     "models.json"
link_file "$PI_DIR/keybindings.json" "$AGENT_DIR/keybindings.json" "keybindings.json"
link_file "$PI_DIR/AGENTS.md"       "$AGENT_DIR/AGENTS.md"       "AGENTS.md"

# ── Link extensions ──────────────────────────────────────────────────

echo ""
info "Linking extensions..."
echo ""

for ext_dir in "$PI_DIR"/extensions/*/; do
  if [[ -d "$ext_dir" ]]; then
    ext_name="$(basename "$ext_dir")"
    link_dir "$ext_dir" "$AGENT_DIR/extensions/$ext_name" "extensions/$ext_name"
  fi
done

# ── Link skills ──────────────────────────────────────────────────────

echo ""
info "Linking skills..."
echo ""

has_skills=false
for skill_dir in "$PI_DIR"/skills/*/; do
  if [[ -d "$skill_dir" ]] && [[ -f "$skill_dir/SKILL.md" ]]; then
    skill_name="$(basename "$skill_dir")"
    link_dir "$skill_dir" "$AGENT_DIR/skills/$skill_name" "skills/$skill_name"
    has_skills=true
  fi
done
if [[ "$has_skills" == false ]]; then
  info "No skills yet (add dirs with SKILL.md to pi/skills/)"
fi

# ── Link prompts ─────────────────────────────────────────────────────

echo ""
info "Linking prompts..."
echo ""

has_prompts=false
for prompt_file in "$PI_DIR"/prompts/*.md; do
  if [[ -f "$prompt_file" ]]; then
    prompt_name="$(basename "$prompt_file")"
    link_file "$prompt_file" "$AGENT_DIR/prompts/$prompt_name" "prompts/$prompt_name"
    has_prompts=true
  fi
done
if [[ "$has_prompts" == false ]]; then
  info "No prompts yet (add .md files to pi/prompts/)"
fi

# ── Link themes ──────────────────────────────────────────────────────

echo ""
info "Linking themes..."
echo ""

has_themes=false
for theme_file in "$PI_DIR"/themes/*.json; do
  if [[ -f "$theme_file" ]]; then
    theme_name="$(basename "$theme_file")"
    link_file "$theme_file" "$AGENT_DIR/themes/$theme_name" "themes/$theme_name"
    has_themes=true
  fi
done
if [[ "$has_themes" == false ]]; then
  info "No themes yet (add .json files to pi/themes/)"
fi

# ── Secrets check ────────────────────────────────────────────────────

echo ""
info "Checking secrets..."
echo ""

if [[ -f "$SECRETS_FILE" ]]; then
  ok "Found ~/.pi-secrets/.env"
else
  warn "No ~/.pi-secrets/.env found"
  echo ""
  echo "  Create it with your API keys:"
  echo ""
  echo "    mkdir -p ~/.pi-secrets && chmod 700 ~/.pi-secrets"
  echo "    cat > ~/.pi-secrets/.env << 'EOF'"
  echo "    MODAL_API_KEY=your-key-here"
  echo "    ANTHROPIC_API_KEY=your-key-here"
  echo "    OPENAI_API_KEY=your-key-here"
  echo "    EOF"
  echo "    chmod 600 ~/.pi-secrets/.env"
  echo ""
fi

# ── Shell integration check ──────────────────────────────────────────

echo ""
info "Checking shell integration..."
echo ""

SHELL_RC=""
if [[ -f "$HOME/.zshrc" ]]; then
  SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
  SHELL_RC="$HOME/.bashrc"
fi

if [[ -n "$SHELL_RC" ]] && grep -q "pi-secrets" "$SHELL_RC" 2>/dev/null; then
  ok "Shell sources ~/.pi-secrets/.env (found in $(basename "$SHELL_RC"))"
else
  warn "Add this to your $(basename "${SHELL_RC:-~/.zshrc}") so API keys load on shell start:"
  echo ""
  echo "    # pi secrets"
  echo "    [ -f ~/.pi-secrets/.env ] && source ~/.pi-secrets/.env"
  echo ""
fi

# ── Done ──────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Setup complete! 🎉           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo "  Next steps:"
echo "    1. Create ~/.pi-secrets/.env with your API keys (if not done)"
echo "    2. Add 'source ~/.pi-secrets/.env' to your shell rc (if not done)"
echo "    3. Run 'pi' — your extensions are ready"
echo "    4. If pi is already running, type '/reload' to pick up changes"
echo ""
