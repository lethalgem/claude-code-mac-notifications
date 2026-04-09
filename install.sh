#!/usr/bin/env bash
set -euo pipefail

# Claude Code macOS Notifications — manual installer
# Copies hook scripts to ~/.claude/hooks/ and merges hook entries into ~/.claude/settings.json

HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Claude Code macOS Notifications..."

# --- Prerequisites ---
if [[ "$(uname)" != "Darwin" ]]; then
  echo "Error: This plugin requires macOS." >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install it with: brew install jq" >&2
  exit 1
fi

# --- Copy hook scripts ---
mkdir -p "$HOOKS_DIR"
for script in notify.sh start-notify.sh ask-notify.sh; do
  cp "$SCRIPT_DIR/hooks/$script" "$HOOKS_DIR/$script"
  chmod +x "$HOOKS_DIR/$script"
done
echo "  Copied 3 hook scripts to $HOOKS_DIR"

# --- Merge settings.json ---
# Create settings.json if it doesn't exist
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# Define the 3 hook entries to add. We check for the command string before inserting
# to keep the installer idempotent.
add_hook() {
  local event="$1"
  local matcher="$2"      # empty string = no matcher
  local command="$3"

  # Check if a hook pointing to the same script filename already exists
  # (handles both ~/... and /Users/foo/... path styles)
  local script_name
  script_name=$(basename "$command")
  local already_present
  already_present=$(jq -r --arg name "$script_name" '
    .hooks // {} | .. | strings | select(endswith($name))
  ' "$SETTINGS" 2>/dev/null || true)

  if [ -n "$already_present" ]; then
    return 0
  fi

  if [ -z "$matcher" ]; then
    # Simple hook: { "hooks": [{ "type": "command", "command": "..." }] }
    jq --arg event "$event" --arg cmd "$command" '
      .hooks[$event] = ((.hooks[$event] // []) + [{"hooks": [{"type": "command", "command": $cmd}]}])
    ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  else
    # Matched hook: { "matcher": "...", "hooks": [...] }
    jq --arg event "$event" --arg matcher "$matcher" --arg cmd "$command" '
      .hooks[$event] = ((.hooks[$event] // []) + [{"matcher": $matcher, "hooks": [{"type": "command", "command": $cmd}]}])
    ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  fi
}

add_hook "UserPromptSubmit" "" "bash $HOOKS_DIR/start-notify.sh"
add_hook "Stop"             "" "bash $HOOKS_DIR/notify.sh"
add_hook "PreToolUse"  "AskUserQuestion" "bash $HOOKS_DIR/ask-notify.sh"

echo "  Merged hook entries into $SETTINGS"
echo ""
echo "Done! Restart Claude Code to activate notifications."
