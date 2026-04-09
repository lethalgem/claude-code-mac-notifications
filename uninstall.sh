#!/usr/bin/env bash
set -euo pipefail

HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS="$HOME/.claude/settings.json"

echo "Uninstalling Claude Code macOS Notifications..."

# --- Remove hook scripts ---
for script in notify.sh start-notify.sh ask-notify.sh; do
  rm -f "$HOOKS_DIR/$script"
done
echo "  Removed hook scripts from $HOOKS_DIR"

# --- Remove hook entries from settings.json ---
if [ -f "$SETTINGS" ] && command -v jq &>/dev/null; then
  COMMANDS=(
    "bash $HOOKS_DIR/start-notify.sh"
    "bash $HOOKS_DIR/notify.sh"
    "bash $HOOKS_DIR/ask-notify.sh"
  )

  for cmd in "${COMMANDS[@]}"; do
    jq --arg cmd "$cmd" '
      .hooks |= (
        if . then
          with_entries(
            .value |= map(
              if (.hooks // []) | map(.command) | contains([$cmd]) then empty
              else .
              end
            )
          )
        else .
        end
      )
    ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
  done
  echo "  Removed hook entries from $SETTINGS"
fi

echo ""
echo "Done! Restart Claude Code to deactivate notifications."
