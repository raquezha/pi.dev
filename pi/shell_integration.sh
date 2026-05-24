#!/usr/bin/env bash
#
# pi.dev shell integration
#
# This wrapper handles custom flags like --android, --plan, etc.
# to inject specialized skills and mindsets into the 'pi' session.

pi() {
  local REPO_DIR="$HOME/RQZ/personal/pi.dev"
  local SKILLS_DIR="$REPO_DIR/pi/skills"
  local CODEX_PKG_NAME="@howaboua/pi-codex-conversion"
  local CODEX_PKG_CACHE_DIR="$HOME/.pi/agent/external-packages/pi-codex-conversion"
  local CODEX_PKG_PATH="$CODEX_PKG_CACHE_DIR/node_modules/@howaboua/pi-codex-conversion"
  
  # Always clear the mindset at the start of the function
  export PI_MINDSET=""
  
  local ARGS=()
  local EXTRA_SKILLS=()
  local EXTRA_EXTENSIONS=()
  local MINDSET=""
  local AUTO_PROVIDER=""
  local AUTO_MODEL=""
  local AUTO_PRIORITY=0
  local EXPLICIT_MODEL=0

  ensure_codex_package() {
    if [[ -d "$CODEX_PKG_PATH" ]]; then
      return
    fi

    if ! command -v npm >/dev/null 2>&1; then
      echo -e "\033[0;31m❌\033[0m npm is required for --codex but was not found" >&2
      return 1
    fi

    echo -e "\033[0;36m▸\033[0m Installing $CODEX_PKG_NAME for --codex..."
    mkdir -p "$CODEX_PKG_CACHE_DIR"
    npm install --omit=dev --prefix "$CODEX_PKG_CACHE_DIR" "$CODEX_PKG_NAME" >/dev/null || return 1
  }

  refresh_codex_package() {
    if ! command -v npm >/dev/null 2>&1; then
      echo -e "\033[0;31m❌\033[0m npm is required for --codex-update but was not found" >&2
      return 1
    fi

    echo -e "\033[0;36m▸\033[0m Refreshing $CODEX_PKG_NAME for --codex..."
    rm -rf "$CODEX_PKG_CACHE_DIR"
    mkdir -p "$CODEX_PKG_CACHE_DIR"
    npm install --omit=dev --prefix "$CODEX_PKG_CACHE_DIR" "$CODEX_PKG_NAME" >/dev/null || return 1
  }

  set_auto_model() {
    local provider="$1"
    local model="$2"
    local priority="$3"

    if [[ "$EXPLICIT_MODEL" -eq 1 ]]; then
      return
    fi

    if (( priority > AUTO_PRIORITY )); then
      AUTO_PROVIDER="$provider"
      AUTO_MODEL="$model"
      AUTO_PRIORITY="$priority"
    fi
  }

  model_for_skill_path() {
    local target="$1"
    local skill_name
    skill_name="$(basename "$target")"

    case "$skill_name" in
      implement|grill-with-docs|android-compose|android-logcat-smart|android-agp9-migration|android-ci-component-adoption|workflow|android)
        set_auto_model "openai-codex" "gpt-5.5" 5
        ;;
      update-docs|pi-skill-creator|meta)
        set_auto_model "openai-codex" "gpt-5.4" 4
        ;;
      frame|plan|agent-os|brave-search|firecrawl|android-adb|android-gradle|android-project-setup|search)
        set_auto_model "github-copilot" "gpt-4.1" 3
        ;;
      cleanup|triage|verify|sync)
        set_auto_model "github-copilot" "gpt-5-mini" 2
        ;;
    esac
  }

  # Parse custom flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --android)
        MINDSET="\033[0;32mandroid\033[0m"
        export PI_MINDSET="android"
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/android")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/triage")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/implement")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/verify")
        model_for_skill_path "$SKILLS_DIR/android"
        model_for_skill_path "$SKILLS_DIR/workflow/triage"
        model_for_skill_path "$SKILLS_DIR/workflow/implement"
        model_for_skill_path "$SKILLS_DIR/workflow/verify"
        shift
        ;;
      --pm)
        MINDSET="\033[0;35mpm\033[0m"
        export PI_MINDSET="pm"
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/search")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/triage")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/frame")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/grill-with-docs")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/plan")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/sync")
        model_for_skill_path "$SKILLS_DIR/search"
        model_for_skill_path "$SKILLS_DIR/workflow/triage"
        model_for_skill_path "$SKILLS_DIR/workflow/frame"
        model_for_skill_path "$SKILLS_DIR/workflow/grill-with-docs"
        model_for_skill_path "$SKILLS_DIR/workflow/plan"
        model_for_skill_path "$SKILLS_DIR/workflow/sync"
        shift
        ;;
      --dev)
        MINDSET="\033[0;33mdev\033[0m"
        export PI_MINDSET="dev"
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/search")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/triage")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/implement")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/verify")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/sync")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/cleanup")
        model_for_skill_path "$SKILLS_DIR/search"
        model_for_skill_path "$SKILLS_DIR/workflow/triage"
        model_for_skill_path "$SKILLS_DIR/workflow/implement"
        model_for_skill_path "$SKILLS_DIR/workflow/verify"
        model_for_skill_path "$SKILLS_DIR/workflow/sync"
        model_for_skill_path "$SKILLS_DIR/workflow/cleanup"
        shift
        ;;
      --rpiv)
        MINDSET="\033[0;34mRPIV\033[0m"
        export PI_MINDSET="rpiv"
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/search")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/triage")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/frame")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/grill-with-docs")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/plan")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/implement")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/verify")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/sync")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/update-docs")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/cleanup")
        model_for_skill_path "$SKILLS_DIR/search"
        model_for_skill_path "$SKILLS_DIR/workflow/triage"
        model_for_skill_path "$SKILLS_DIR/workflow/frame"
        model_for_skill_path "$SKILLS_DIR/workflow/grill-with-docs"
        model_for_skill_path "$SKILLS_DIR/workflow/plan"
        model_for_skill_path "$SKILLS_DIR/workflow/implement"
        model_for_skill_path "$SKILLS_DIR/workflow/verify"
        model_for_skill_path "$SKILLS_DIR/workflow/sync"
        model_for_skill_path "$SKILLS_DIR/workflow/update-docs"
        model_for_skill_path "$SKILLS_DIR/workflow/cleanup"
        shift
        ;;
      --meta)
        MINDSET="\033[0;35mmeta\033[0m"
        export PI_MINDSET="meta"
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/meta" "--skill" "$SKILLS_DIR/search" "--extension" "$REPO_DIR/pi/extensions/env-protection/index.ts")
        model_for_skill_path "$SKILLS_DIR/meta"
        model_for_skill_path "$SKILLS_DIR/search"
        shift
        ;;
      --write)
        MINDSET="\033[0;34mwrite\033[0m"
        export PI_MINDSET="write"
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/search")
        model_for_skill_path "$SKILLS_DIR/search"
        shift
        ;;
      --antigravity)
        MINDSET="\033[0;31mantigravity\033[0m"
        export PI_MINDSET="antigravity"
        EXTRA_EXTENSIONS+=("--extension" "$REPO_DIR/pi/extensions/antigravity-auth-login")
        shift
        ;;
      --codex)
        MINDSET="\033[0;36mcodex\033[0m"
        export PI_MINDSET="codex"
        ensure_codex_package || return 1
        EXTRA_EXTENSIONS+=("--extension" "$CODEX_PKG_PATH")
        set_auto_model "openai-codex" "gpt-5.5" 6
        shift
        ;;
      --codex-update)
        MINDSET="\033[0;36mcodex\033[0m"
        export PI_MINDSET="codex"
        refresh_codex_package || return 1
        EXTRA_EXTENSIONS+=("--extension" "$CODEX_PKG_PATH")
        set_auto_model "openai-codex" "gpt-5.5" 6
        shift
        ;;
      --skill)
        ARGS+=("$1")
        if [[ $# -gt 1 ]]; then
          model_for_skill_path "$2"
          ARGS+=("$2")
          shift 2
        else
          shift
        fi
        ;;
      --skill=*)
        ARGS+=("$1")
        model_for_skill_path "${1#--skill=}"
        shift
        ;;
      --model)
        EXPLICIT_MODEL=1
        ARGS+=("$1")
        if [[ $# -gt 1 ]]; then
          ARGS+=("$2")
          shift 2
        else
          shift
        fi
        ;;
      --model=*)
        EXPLICIT_MODEL=1
        ARGS+=("$1")
        shift
        ;;
      --provider)
        EXPLICIT_MODEL=1
        ARGS+=("$1")
        if [[ $# -gt 1 ]]; then
          ARGS+=("$2")
          shift 2
        else
          shift
        fi
        ;;
      --provider=*)
        EXPLICIT_MODEL=1
        ARGS+=("$1")
        shift
        ;;
      --models)
        EXPLICIT_MODEL=1
        ARGS+=("$1")
        if [[ $# -gt 1 ]]; then
          ARGS+=("$2")
          shift 2
        else
          shift
        fi
        ;;
      --models=*)
        EXPLICIT_MODEL=1
        ARGS+=("$1")
        shift
        ;;
      *)
        ARGS+=("$1")
        shift
        ;;
    esac
  done

  if [[ "$EXPLICIT_MODEL" -eq 1 ]]; then
    AUTO_PROVIDER=""
    AUTO_MODEL=""
    AUTO_PRIORITY=0
  fi

  if [[ -n "$MINDSET" ]]; then
    echo -e "\033[0;36m▸\033[0m Mindset: $MINDSET"
  fi

  local MODEL_ARGS=()
  if [[ -n "$AUTO_MODEL" ]]; then
    MODEL_ARGS+=("--provider" "$AUTO_PROVIDER" "--model" "$AUTO_MODEL")
    echo -e "\033[0;36m▸\033[0m Model: ${AUTO_PROVIDER}/${AUTO_MODEL} (auto)"
  fi

  # Run the real pi with injected skills/extensions and original arguments
  command pi "${EXTRA_SKILLS[@]}" "${EXTRA_EXTENSIONS[@]}" "${MODEL_ARGS[@]}" "${ARGS[@]}"
  
  # Reset mindset for subsequent calls in the same shell
  unset PI_MINDSET
}

alias reload-pi="source $HOME/RQZ/personal/pi.dev/pi/shell_integration.sh && echo 'pi.dev shell integration reloaded'"
