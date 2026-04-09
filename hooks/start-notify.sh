#!/usr/bin/env bash
# Claude Code task-start notification

# Consume stdin
cat > /dev/null

osascript -e 'display notification "Claude is working..." with title "Claude Code"'
