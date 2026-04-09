# Claude Code macOS Notifications

Native macOS notification banners and sounds for [Claude Code](https://claude.ai/code) — so you can step away while Claude works and get tapped on the shoulder at the right moments.

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-%E2%98%95-yellow)](https://buymeacoffee.com/iancashdeveloper)

---

## What it does

| Event | Notification | Sound |
|---|---|---|
| You submit a prompt | "Claude is working..." | — |
| Claude finishes its turn | "Ready for your next message" | Glass chime |
| Claude needs your input | "Claude needs your input" | Blow |

The turn-end notification is suppressed when Claude launches a background agent (it'll auto-resume without your input).

---

## Requirements

- macOS (uses `osascript` and `afplay`)
- [Claude Code](https://claude.ai/code) installed
- `jq` installed: `brew install jq`

---

## Install

### Via Claude Code plugin system (recommended)

```
/plugin marketplace add lethalgem/claude-code-mac-notifications
/plugin install claude-code-mac-notifications
```

### Manual install

```bash
git clone https://github.com/lethalgem/claude-code-mac-notifications.git
cd claude-code-mac-notifications
./install.sh
```

---

## Uninstall

```bash
./uninstall.sh
```

Or remove the hook entries from `~/.claude/settings.json` and delete `~/.claude/hooks/{notify,start-notify,ask-notify}.sh`.

---

## License

MIT — see [LICENSE](LICENSE).
