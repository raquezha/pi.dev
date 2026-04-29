#!/usr/bin/env bash
#
# pi.dev shell integration
#
# This wrapper handles custom flags like --android, --plan, etc.
# to inject specialized skills and mindsets into the 'pi' session.

pi() {
  local REPO_DIR="$HOME/Developer/pi.dev"
  local SKILLS_DIR="$REPO_DIR/pi/skills"
  
  local ARGS=()
  local EXTRA_SKILLS=()
  local MINDSET=""

  # Parse custom flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --android)
        MINDSET="\033[0;32mandroid\033[0m"
        export PI_MINDSET="android"
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/android")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/investigate")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/implement-plan")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow/verify-changes")
        shift
        ;;
      --plan)
        MINDSET="\033[0;33mplan\033[0m"
        export PI_MINDSET="plan"
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/search")
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/workflow")
        shift
        ;;
      --meta)
        MINDSET="\033[0;35mmeta\033[0m"
        export PI_MINDSET="meta"
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/meta" "--skill" "$SKILLS_DIR/search" "--extension" "$REPO_DIR/pi/extensions/env-protection/index.ts")
        shift
        ;;
      --write)
        MINDSET="\033[0;34mwrite\033[0m"
        export PI_MINDSET="write"
        EXTRA_SKILLS+=("--skill" "$SKILLS_DIR/search")
        shift
        ;;
      *)
        ARGS+=("$1")
        shift
        ;;
    esac
  done

  if [[ -n "$MINDSET" ]]; then
    echo -e "\033[0;36m▸\033[0m Mindset: $MINDSET"
  fi

  # Run the real pi with injected skills and original arguments
  command pi "${EXTRA_SKILLS[@]}" "${ARGS[@]}"
}
