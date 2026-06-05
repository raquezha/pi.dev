#!/usr/bin/env bash
set -euo pipefail

# 1. Detect OS Platform
OS="$(uname -s)"
case "$OS" in
  Darwin)
    echo "Installing tools via Homebrew..."
    brew install node tmux git gh go rsync
    ;;
  Linux)
    if [ -f /etc/arch-release ] || command -v pacman &>/dev/null; then
      echo "Installing tools via pacman..."
      sudo pacman -S --needed --noconfirm nodejs npm tmux git github-cli go rsync
    elif command -v apt-get &>/dev/null; then
      echo "Installing tools via apt-get..."
      sudo apt-get update && sudo apt-get install -y nodejs npm tmux git github-cli golang rsync
    fi
    ;;
esac

# 2. Install Pi Coding Agent and extensions from NPM
echo "Installing packages from NPM..."
npm install -g @mariozechner/pi-coding-agent
npm install -g nothing-notrace nothing-noleaks

# 3. Mount configurations
mkdir -p "$HOME/.pi/agent"
cp settings.json "$HOME/.pi/agent/settings.json"
cp mindsets.json "$HOME/.pi/agent/mindsets.json"
echo "Bootstrap complete! 🎉"
