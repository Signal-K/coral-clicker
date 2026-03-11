# Claude Code Rules

## Git

- **NEVER commit without explicit user instruction.** Do not commit as part of completing a task, cleanup, or any other work unless the user directly says to commit.
- **NEVER push without explicit user instruction.**
- When work is done, leave changes unstaged unless told otherwise.
- A stop hook (`~/.claude/stop-hook-git-check.sh`) will block session end if there are uncommitted changes or unpushed commits. When it fires, **ask the user** whether they want to commit and push — do not do it automatically.

## Commit Format

All commits must follow this format:

```
<emoji1><emoji2> ↝ [ticket-id(s)]: Commit message
```

- Two random non-flag, non-symbol emojis (e.g. not ␦ ♎︎ 🟢 🆓 ♐️)
- Neither emoji may have appeared in the last 20 commits — check `git log --oneline -20` first
- The arrow is exactly `↝` (U+219D)
- Ticket IDs from knowns (e.g. `[q8bgdg lkzqm0 ++]`); use `++` alone if no specific ticket applies
- Example: `🗻🌨️ ↝ [q8bgdg lkzqm0 ++]: New specs`
