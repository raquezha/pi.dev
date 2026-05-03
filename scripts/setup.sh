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

# ── Symlink helpers ───────────────────────────────────────────────────

link_item() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [[ ! -e "$src" ]]; then
    warn "Skipping $label (source not found: $src)"
    return
  fi

  # If destination exists and is not a symlink, back it up
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    local backup="$dest.backup.$(date +%s)"
    mv "$dest" "$backup"
    warn "Backed up existing $label → $(basename "$backup")"
  fi

  # If it's a symlink, check if it points to the right place
  if [[ -L "$dest" ]]; then
    local current_target
    current_target="$(readlink "$dest")"
    if [[ "$current_target" == "$src" ]]; then
      ok "$label (already linked)"
      return
    fi
    rm "$dest"
  fi

  ln -s "$src" "$dest"
  ok "Linked $label"
}

# prune_dir <target_dir> <source_dir> <label>
# Removes symlinks in target_dir that don't have a corresponding item in source_dir
prune_links() {
  local target_dir="$1"
  local source_dir="$2"
  local label="$3"

  if [[ ! -d "$target_dir" ]]; then return; fi

  shopt -s nullglob
  for link in "$target_dir"/*; do
    if [[ -L "$link" ]]; then
      local filename
      filename="$(basename "$link")"
      if [[ ! -e "$source_dir/$filename" ]]; then
        rm "$link"
        warn "Pruned orphaned link: $label/$filename"
      fi
    fi
  done
  shopt -u nullglob
}

# ── Link low-context-bloat defaults ──────────────────────────────────

echo ""
info "Linking low-context-bloat defaults..."
echo ""

# Safe defaults: config, models, keybindings, themes, and core UI extensions.
# Intentionally NOT linked by default: AGENTS.md, skills, prompts, and manual-only extensions.
# Those are opt-in because they increase startup context or behavior surface.
link_item "$PI_DIR/settings.json"    "$AGENT_DIR/settings.json"    "settings.json"
link_item "$PI_DIR/models.json"      "$AGENT_DIR/models.json"      "models.json"
link_item "$PI_DIR/keybindings.json" "$AGENT_DIR/keybindings.json" "keybindings.json"

# ── Link extensions ──────────────────────────────────────────────────

echo ""
info "Syncing extensions..."
echo ""

# Prune extensions no longer in repo
prune_links "$AGENT_DIR/extensions" "$PI_DIR/extensions" "extensions"

# Link specific extensions (opt-in)
link_item "$PI_DIR/extensions/powerline-footer" "$AGENT_DIR/extensions/powerline-footer" "extensions/powerline-footer"
link_item "$PI_DIR/extensions/clean-repo"       "$AGENT_DIR/extensions/clean-repo"       "extensions/clean-repo"

# Manual-only extensions are not linked here. Load them explicitly when needed.
if [[ -L "$AGENT_DIR/extensions/gemini-api" ]]; then
  rm "$AGENT_DIR/extensions/gemini-api"
  warn "Removed manual-only extensions/gemini-api; load it with pi -e ./pi/extensions/gemini-api"
fi
if [[ -L "$AGENT_DIR/extensions/antigravity-auth-login" ]]; then
  rm "$AGENT_DIR/extensions/antigravity-auth-login"
  warn "Removed manual-only extensions/antigravity-auth-login; use pi --antigravity or pi -e ./pi/extensions/antigravity-auth-login"
fi

# ── Link prompts ─────────────────────────────────────────────────────

echo ""
info "Syncing prompts..."
echo ""

# Prune prompts no longer in repo
prune_links "$AGENT_DIR/prompts" "$PI_DIR/prompts" "prompts"

has_prompts=false
for prompt_file in "$PI_DIR"/prompts/*.md; do
  if [[ -f "$prompt_file" ]]; then
    prompt_name="$(basename "$prompt_file")"
    link_item "$prompt_file" "$AGENT_DIR/prompts/$prompt_name" "prompts/$prompt_name"
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

# Aggressively remove any existing user-visible themes and installed theme packages,
# then link only the dracula theme from this repo.
if [[ -d "$AGENT_DIR/themes" ]]; then
  shopt -s nullglob
  for f in "$AGENT_DIR/themes"/*; do
    base="$(basename "$f")"
    if [[ "$base" == ".gitkeep" ]]; then
      continue
    fi
    if [[ -L "$f" || -f "$f" || -d "$f" ]]; then
      rm -rf "$f"
      ok "Removed $AGENT_DIR/themes/$base"
    fi
  done
  shopt -u nullglob
fi

# Remove installed package directories that provide extra themes
if [[ -d "$AGENT_DIR/git/github.com/hasit/pi-community-themes" ]]; then
  rm -rf "$AGENT_DIR/git/github.com/hasit/pi-community-themes"
  ok "Removed installed package: hasit/pi-community-themes"
fi
if [[ -d "$AGENT_DIR/npm/pi-rose-pine" ]]; then
  rm -rf "$AGENT_DIR/npm/pi-rose-pine"
  ok "Removed installed package: pi-rose-pine"
fi

# Link custom dracula themes from this repo
if [[ -f "$PI_DIR/themes/dracula-vibrant.json" ]]; then
  link_item "$PI_DIR/themes/dracula-vibrant.json" "$AGENT_DIR/themes/dracula-vibrant.json" "themes/dracula-vibrant.json"
fi
if [[ -f "$PI_DIR/themes/ghostly-pale.json" ]]; then
  link_item "$PI_DIR/themes/ghostly-pale.json" "$AGENT_DIR/themes/ghostly-pale.json" "themes/ghostly-pale.json"
fi

# ── Available Inventory Summary ──────────────────────────────────────

echo ""
info "Checking available (not linked) items..."
echo ""

show_available() {
  local src_dir="$1"
  local dest_dir="$2"
  local label="$3"

  echo -e "${YELLOW}$label library:${NC}"
  local count=0
  for item in "$src_dir"/*; do
    local name
    name="$(basename "$item")"
    if [[ ! -e "$dest_dir/$name" ]]; then
      echo "  - $name"
      count=$((count + 1))
    fi
  done
  if [[ $count -eq 0 ]]; then
    echo "  (all linked)"
  fi
}

show_available "$PI_DIR/skills" "$AGENT_DIR/skills" "Skills"
echo ""
show_available "$PI_DIR/extensions" "$AGENT_DIR/extensions" "Extensions"

# ── Auto-link workflow skills (Core to R&D Workflow) ─────────────────

# Skipped auto-linking; these are injected via 'pi --plan' or 'pi --android'
# shell integration to avoid context bloat in standard sessions.

echo ""
info "Skipped by default to avoid context bloat: AGENTS.md, skills"

echo ""
info "Skipped by default to avoid context bloat: AGENTS.md, skills"
info "Enable skills manually by linking them to $AGENT_DIR/skills/"

# ── Secrets check ────────────────────────────────────────────────────

echo ""
info "Checking secrets..."
echo ""

if [[ -f "$SECRETS_FILE" ]]; then
  ok "Found ~/.pi-secrets/.env"
  
  # Check for specific required keys
  if ! grep -q "BRAVE_SEARCH_API_KEY" "$SECRETS_FILE"; then
    warn "BRAVE_SEARCH_API_KEY is missing from ~/.pi-secrets/.env"
    info "Get one at: https://api.search.brave.com/app/dashboard"
    info "To add it, run: echo \"BRAVE_SEARCH_API_KEY=your_key_here\" >> $SECRETS_FILE"
  fi
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

INTEGRATION_FILE="$REPO_DIR/pi/shell_integration.sh"
SOURCE_LINE="[ -f $INTEGRATION_FILE ] && source $INTEGRATION_FILE"

if [[ -n "$SHELL_RC" ]]; then
  if grep -q "shell_integration.sh" "$SHELL_RC" 2>/dev/null; then
    ok "Shell sources pi.dev shell_integration.sh (found in $(basename "$SHELL_RC"))"
  else
    echo "$SOURCE_LINE" >> "$SHELL_RC"
    ok "Added shell_integration.sh to $(basename "$SHELL_RC")"
    info "Run 'source $SHELL_RC' or open a new terminal to enable 'pi android' etc."
  fi
else
  warn "Could not find .zshrc or .bashrc to add shell integration."
fi

if [[ -n "$SHELL_RC" ]] && grep -q "pi-secrets" "$SHELL_RC" 2>/dev/null; then
  ok "Shell sources ~/.pi-secrets/.env (found in $(basename "$SHELL_RC"))"
else
  warn "Add this to your $(basename "${SHELL_RC:-~/.zshrc}") so API keys load on shell start:"
  echo ""
  echo "    # pi secrets"
  echo "    if [ -f ~/.pi-secrets/.env ]; then"
  echo "      export \$(grep -v '^#' ~/.pi-secrets/.env | xargs)"
  echo "    fi"
  echo ""
fi

# ── Done ──────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Setup complete! 🎉           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo "  Next steps (The Hierarchy):"
echo ""
echo "  1. GLOBAL MACHINE SETUP (Once per Mac)"
echo "     - Install Pi:     npm install -g @mariozechner/pi-coding-agent"
echo "     - Install Entire: curl -fsSL https://entire.io/install.sh | bash"
echo "     - Login:          entire login"
echo "     - Build Agent:    ./scripts/install-entire-agent.sh"
echo "     - Optional:       Install tmux (brew install tmux) for multitasking"
echo ""
echo "  2. PI.DEV CONFIGURATION (Once per Mac)"
echo "     - Link pi.dev:    ./scripts/setup.sh (You just did this!)"
echo "     - Secrets:        Create ~/.pi-secrets/.env with your API keys"
echo "     - Shell:          Add 'source ~/.pi-secrets/.env' to your ~/.zshrc"
echo ""
echo "  3. PROJECT ACTIVATION (Once per Repo/Project)"
echo "     - Enable Entire:  entire enable"
echo "     - Enable Pi:      entire-agent-pi install-hooks"
echo ""
echo "  4. START WORKING"
echo "     - Run 'pi' in your project repo."
echo "     - Use 'pi --antigravity' when you want the Antigravity extension loaded."
echo "     - If pi is already running, type '/reload' inside pi."
echo ""

# ── Quick developer guidance: Go toolchain & tmux checks ──────────────
if command -v go >/dev/null 2>&1; then
  ok "Go toolchain found ($(go version))"
else
  warn "Go toolchain not found on this machine"
  if command -v brew >/dev/null 2>&1; then
    info "You can install Go with Homebrew. Run these commands:"
    echo "  brew update"
    echo "  brew install go"
    echo "After that, verify with: go version"
  else
    info "Homebrew not found. Install Go manually from https://go.dev/dl/ or install Homebrew first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "Then run: brew install go"
  fi
  echo ""
  info "When Go is installed, run: ./scripts/install-entire-agent.sh to build the entire-agent-pi binary"
fi

echo ""

if command -v tmux >/dev/null 2>&1; then
  TMUX_VER="$(tmux -V | cut -d' ' -f2)"
  ok "tmux found ($TMUX_VER)"

  TMUX_CONF="$HOME/.tmux.conf"
  if [[ -f "$TMUX_CONF" ]]; then
    if grep -q "extended-keys" "$TMUX_CONF"; then
      ok "tmux extended-keys configuration found in $(basename "$TMUX_CONF")"
    else
      warn "tmux found but 'extended-keys' not configured in $(basename "$TMUX_CONF")"
      info "For best pi experience (Shift+Enter support), add to your $(basename "$TMUX_CONF"):"
      echo "    set -g extended-keys on"
      echo "    set -g extended-keys-format csi-u"
    fi
  else
    warn "tmux found but no ~/.tmux.conf found"
    info "For best pi experience (Shift+Enter support), create ~/.tmux.conf with:"
    echo "    set -g extended-keys on"
    echo "    set -g extended-keys-format csi-u"
  fi
else
  info "tmux not found (Optional, but recommended for pi multitasking)"
  if command -v brew >/dev/null 2>&1; then
    info "You can install it with: brew install tmux"
  fi
fi

