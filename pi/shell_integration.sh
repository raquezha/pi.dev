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
  local EXTRA_ARGS=()
  local MINDSETS=()
  local HAS_ANDROID=false
  local HAS_PLAN=false
  local HAS_META=false
  local HAS_WRITE=false

  add_unique_arg_pair() {
    local flag="$1"
    local value="$2"
    local i=0
    while [[ $i -lt ${#EXTRA_ARGS[@]} ]]; do
      if [[ "${EXTRA_ARGS[$i]}" == "$flag" && "${EXTRA_ARGS[$((i + 1))]}" == "$value" ]]; then
        return
      fi
      i=$((i + 2))
    done
    EXTRA_ARGS+=("$flag" "$value")
  }

  add_skill() {
    add_unique_arg_pair "--skill" "$1"
  }

  add_extension() {
    add_unique_arg_pair "--extension" "$1"
  }

  add_mindset() {
    local label="$1"
    local existing
    for existing in "${MINDSETS[@]}"; do
      if [[ "$existing" == "$label" ]]; then
        return
      fi
    done
    MINDSETS+=("$label")
  }

  # Parse custom flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --android)
        HAS_ANDROID=true
        add_mindset "Android Developer"
        add_skill "$SKILLS_DIR/workflow/implement-plan"
        add_skill "$SKILLS_DIR/android/android-adb"
        add_skill "$SKILLS_DIR/android/android-agp9-migration"
        add_skill "$SKILLS_DIR/android/android-ci-component-adoption"
        add_skill "$SKILLS_DIR/android/android-compose"
        add_skill "$SKILLS_DIR/android/android-gradle"
        add_skill "$SKILLS_DIR/android/android-logcat-smart"
        add_skill "$SKILLS_DIR/android/android-project-setup"
        shift
        ;;
      --plan)
        HAS_PLAN=true
        add_mindset "Architect/Planner"
        add_skill "$SKILLS_DIR/search/brave-search"
        add_skill "$SKILLS_DIR/workflow/frame-problem"
        add_skill "$SKILLS_DIR/workflow/ubiquitous-language"
        add_skill "$SKILLS_DIR/workflow/write-a-plan"
        shift
        ;;
      --meta)
        HAS_META=true
        add_mindset "Agent Architect (Meta)"
        add_skill "$SKILLS_DIR/meta/pi-skill-creator"
        add_skill "$SKILLS_DIR/search/brave-search"
        add_extension "$REPO_DIR/pi/extensions/env-protection/index.ts"
        shift
        ;;
      --write)
        HAS_WRITE=true
        add_mindset "Technical Writer"
        add_skill "$SKILLS_DIR/search/brave-search"
        shift
        ;;
      *)
        ARGS+=("$1")
        shift
        ;;
    esac
  done

  local PI_MINDSET_VALUE=""
  if [[ ${#MINDSETS[@]} -eq 1 ]]; then
    PI_MINDSET_VALUE="${MINDSETS[0]}"
  elif [[ ${#MINDSETS[@]} -gt 1 ]]; then
    PI_MINDSET_VALUE="$(IFS=' + '; echo "${MINDSETS[*]}")"
  fi
  export PI_MINDSET="$PI_MINDSET_VALUE"

  if [[ -n "$PI_MINDSET_VALUE" ]]; then
    echo -e "\033[0;36m▸\033[0m Mindset: $PI_MINDSET_VALUE"
  fi

  # Run the real pi with injected skills and original arguments
  command pi "${EXTRA_ARGS[@]}" "${ARGS[@]}"
}
