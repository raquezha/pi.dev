#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
AGENT_DIR="$REPO_ROOT/agents/entire-agent-pi"
DEFAULT_USER_BIN="$HOME/.local/bin"

info()  { echo "[INFO] $1"; }
warn()  { echo "[WARN] $1"; }
err()   { echo "[ERROR] $1"; }

usage() {
  cat <<EOF
Usage: $0 [--dest PATH] [--sudo]

Build and install the entire-agent-pi Go binary.

Options:
  --dest PATH    Install destination directory (default: $DEFAULT_USER_BIN)
  --sudo         Install to system directory (/usr/local/bin) using sudo
  -h, --help     Show this help

This script builds the binary from agents/entire-agent-pi and installs it.
Recommended (no sudo): use the default user-local directory: $DEFAULT_USER_BIN
EOF
}

DEST="$DEFAULT_USER_BIN"
USE_SUDO=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest)
      DEST="$2"; shift 2;;
    --sudo)
      USE_SUDO=true; DEST="/usr/local/bin"; shift;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

# Check for Go
if ! command -v go >/dev/null 2>&1; then
  err "Go not found. Install Go (https://go.dev/dl/) and re-run this script."
  exit 1
fi

# Ensure agent source exists; if not, fetch a copy into a temp dir
CLEANUP_TEMP_CLONE=false
if [[ ! -d "$AGENT_DIR" ]]; then
  warn "Agent source not found at: $AGENT_DIR"
  if ! command -v git >/dev/null 2>&1; then
    err "git not found. Install git and re-run, or clone https://github.com/entireio/external-agents manually into your repo's agents/ directory."
    exit 1
  fi
  TEMP_DIR="$(mktemp -d /tmp/external-agents-XXXX)"
  info "Cloning external-agents to temporary dir: $TEMP_DIR"
  if git clone --depth 1 https://github.com/entireio/external-agents "$TEMP_DIR" >/dev/null 2>&1; then
    AGENT_DIR="$TEMP_DIR/agents/entire-agent-pi"
    CLEANUP_TEMP_CLONE=true
  else
    err "git clone failed. Please clone https://github.com/entireio/external-agents manually and re-run."
    exit 1
  fi
fi

info "Building entire-agent-pi from: $AGENT_DIR"
pushd "$AGENT_DIR" >/dev/null
if go build -o entire-agent-pi ./cmd/entire-agent-pi; then
  info "Build succeeded"
else
  err "go build failed"
  popd >/dev/null
  if [[ "$CLEANUP_TEMP_CLONE" == true ]]; then
    rm -rf "$TEMP_DIR" || true
  fi
  exit 1
fi
popd >/dev/null

# Ensure DEST exists
if [[ "$USE_SUDO" == "true" ]]; then
  info "Installing to system directory: $DEST (using sudo)"
  sudo mkdir -p "$DEST"
  sudo mv -f "$AGENT_DIR/entire-agent-pi" "$DEST/entire-agent-pi"
  sudo chmod 0755 "$DEST/entire-agent-pi"
else
  info "Installing to user-local directory: $DEST"
  mkdir -p "$DEST"
  mv -f "$AGENT_DIR/entire-agent-pi" "$DEST/entire-agent-pi"
  chmod 0755 "$DEST/entire-agent-pi"
fi

# Clean up temp clone if used
if [[ "$CLEANUP_TEMP_CLONE" == true ]]; then
  info "Removing temporary clone: $TEMP_DIR"
  rm -rf "$TEMP_DIR" || true
fi

# Verify installation
if command -v entire-agent-pi >/dev/null 2>&1; then
  info "entire-agent-pi installed and available on PATH"
else
  warn "installed to $DEST, but entire-agent-pi not found on PATH"
  echo
  warn "Add the installation directory to your shell rc (e.g. ~/.zshrc):"
  echo "  export PATH=\"$DEST:\\$PATH\""
  echo
fi

info "Verify by running: entire-agent-pi --help"

info "To enable hooks in a repository, run inside that repo:"
info "  entire-agent-pi install-hooks"

exit 0
