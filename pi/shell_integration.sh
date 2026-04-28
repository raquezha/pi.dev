#!/usr/bin/env bash
#
# pi.dev shell integration
#
# This file provides a wrapper function for the 'pi' command to support 
# custom workflows (subcommands) like 'pi android' or 'pi plan'.

pi() {
  local REPO_DIR="$HOME/Developer/pi.dev"
  local SKILLS_DIR="$REPO_DIR/pi/skills"

  # Case 1: 'pi android' - Load all android-related skills
  if [[ "$1" == "android" ]]; then
    shift
    echo -e "\033[0;36m▸\033[0m Mindset: \033[0;32mAndroid Developer\033[0m"
    command pi --skill "$SKILLS_DIR/android" "$@"
    return
  fi

  # Case 2: 'pi plan' - Load planning and search skills
  if [[ "$1" == "plan" ]]; then
    shift
    echo -e "\033[0;36m▸\033[0m Mindset: \033[0;33mArchitect/Planner\033[0m"
    command pi --skill "$SKILLS_DIR/search" "$@"
    return
  fi

  # Case 3: 'pi meta' - Load agent management skills
  if [[ "$1" == "meta" ]]; then
    shift
    echo -e "\033[0;36m▸\033[0m Mindset: \033[0;35mAgent Architect (Meta)\033[0m"
    command pi --skill "$SKILLS_DIR/meta" --skill "$SKILLS_DIR/search" "$@"
    return
  fi

  # Case 4: 'pi write' - Load documentation/writing skills
  if [[ "$1" == "write" ]]; then
    shift
    echo -e "\033[0;36m▸\033[0m Mindset: \033[0;34mTechnical Writer\033[0m"
    # Assuming search might be needed for fact-checking while writing
    command pi --skill "$SKILLS_DIR/search" "$@"
    return
  fi

  # Case 3: 'pi docs' - Access pi.dev documentation
  if [[ "$1" == "docs" ]]; then
    echo -e "\033[0;36m▸\033[0m Opening \033[0;32mpi.dev documentation\033[0m..."
    ls /opt/homebrew/lib/node_modules/@mariozechner/pi-coding-agent/docs/
    return
  fi

  # Default: Pass everything to the real pi binary
  command pi "$@"
}
