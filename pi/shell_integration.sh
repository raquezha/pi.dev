#!/usr/bin/env bash
#
# pi.dev shell integration
#
# This wrapper handles custom flags like --android, --plan, etc.
# to inject specialized skills and mindsets into the 'pi' session.

pi() {
  local REPO_DIR="$HOME/Developer/pi.dev"
  local SKILLS_DIR="$REPO_DIR/pi/skills"
  
  # Always clear the mindset at the start of the function
  export PI_MINDSET=""
  
  local ARGS=()
  local EXTRA_SKILLS=()
  local EXTRA_EXTENSIONS=()
  local MINDSET=""

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
      --antigravity)
        MINDSET="\033[0;31mantigravity\033[0m"
        export PI_MINDSET="antigravity"
        EXTRA_EXTENSIONS+=("--extension" "$REPO_DIR/pi/extensions/antigravity-auth-login")
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

  # Run the real pi with injected skills/extensions and original arguments
  command pi "${EXTRA_SKILLS[@]}" "${EXTRA_EXTENSIONS[@]}" "${ARGS[@]}"
  
  # Reset mindset for subsequent calls in the same shell
  unset PI_MINDSET
}
