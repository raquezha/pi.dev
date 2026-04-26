#!/usr/bin/env bash
set -euo pipefail

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required but not installed" >&2
  exit 127
fi

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <command...>" >&2
  echo "Runs the given command inside a temporary detached tmux session, waits for it to finish, prints captured output, and removes the session." >&2
  exit 2
fi

# join all args into a single command string
cmd="$*"

session="pi_tmux_${RANDOM}_$$"
statusfile=$(mktemp /tmp/pi_tmux_status.XXXX)
outfile=$(mktemp /tmp/pi_tmux_out.XXXX)
scriptfile=$(mktemp /tmp/pi_tmux_script.XXXX)

cleanup() {
  # best-effort cleanup
  tmux kill-session -t "$session" >/dev/null 2>&1 || true
  rm -f "$scriptfile" "$statusfile" "$outfile" >/dev/null 2>&1 || true
}

trap cleanup EXIT

# Create a script the tmux session will execute. This avoids tricky quoting issues.
cat > "$scriptfile" <<- 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# user command goes here
USER_COMMAND_PLACEHOLDER

echo "__TMUX_EXIT_CODE:$?" > STATUS_FILE_PLACEHOLDER
EOF

# Replace placeholders with safe-escaped values
# Use printf %q for the command so it is safe inside the script
escaped_cmd=$(printf "%q" "$cmd")
escaped_status=$(printf "%q" "$statusfile")

eval "sed -i '' -e 's|USER_COMMAND_PLACEHOLDER|$escaped_cmd|g' '$scriptfile'" 2>/dev/null || \
  sed -i -e "s|USER_COMMAND_PLACEHOLDER|$escaped_cmd|g" "$scriptfile"

eval "sed -i '' -e 's|STATUS_FILE_PLACEHOLDER|$escaped_status|g' '$scriptfile'" 2>/dev/null || \
  sed -i -e "s|STATUS_FILE_PLACEHOLDER|$escaped_status|g" "$scriptfile"

chmod +x "$scriptfile"

# Start detached tmux session that runs the script
# Use a login shell so PATH and environment are similar to interactive shells
tmux new-session -d -s "$session" "bash '$scriptfile'"

# Wait for status file or timeout
timeout=${TMUX_RUN_TIMEOUT:-60}
end=$((SECONDS + timeout))
while [[ ! -f "$statusfile" && SECONDS -lt end ]]; do
  sleep 0.05
done

# Capture pane contents (full scrollback)
# -J joins wrapped lines; -p prints the contents
tmux capture-pane -J -p -t "$session" > "$outfile" 2>/dev/null || true

if [[ -f "$statusfile" ]]; then
  exit_code=$(sed -n 's/^__TMUX_EXIT_CODE:\([0-9]*\)$/\1/p' "$statusfile" || echo 0)
else
  echo "Timed out waiting for tmux command to finish (timeout=${timeout}s)" >&2
  exit_code=124
fi

# Print captured output
cat "$outfile"

# Explicitly kill session (cleanup trap will also attempt)
tmux kill-session -t "$session" >/dev/null 2>&1 || true

# remove tmp files (trap will also remove)
rm -f "$scriptfile" "$statusfile" "$outfile" >/dev/null 2>&1 || true

exit "$exit_code"
