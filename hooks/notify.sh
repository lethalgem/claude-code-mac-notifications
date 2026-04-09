#!/usr/bin/env bash
# Claude Code turn-end notification
# Plays a chime and shows a macOS notification banner.
# Only suppresses for background agents (Claude will auto-resume — no action needed).

PAYLOAD=$(cat)
TRANSCRIPT_PATH=$(echo "$PAYLOAD" | jq -r '.transcript_path // empty')

# Check if a background agent was just launched
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  IS_BACKGROUND=$(jq -rs '
    [.[] | select(.type == "assistant")] | last
    | [.message.content[]? | select(.type == "tool_use" and .name == "Agent") | .input.run_in_background // false]
    | last // false
  ' "$TRANSCRIPT_PATH" 2>/dev/null)

  if [ "$IS_BACKGROUND" = "true" ]; then
    exit 0
  fi
fi

afplay /System/Library/Sounds/Glass.aiff &
osascript -e 'display notification "Ready for your next message" with title "Claude Code"'
