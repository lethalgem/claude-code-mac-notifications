#!/usr/bin/env bash
# Fires when Claude is about to ask the user a question via AskUserQuestion.
# Notifies the user that their input is needed.

cat > /dev/null  # consume stdin

afplay /System/Library/Sounds/Blow.aiff &
osascript -e 'display notification "Claude needs your input" with title "Claude Code"'
