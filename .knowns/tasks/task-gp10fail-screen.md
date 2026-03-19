---
id: gp10fail-screen
title: "Fail screen — reason, XP notice, restart/back"
status: todo
priority: medium
labels:
  - gameplay
  - ui
createdAt: '2026-03-17T00:00:00Z'
updatedAt: '2026-03-17T00:00:00Z'
---

# Fail screen — reason, XP notice, restart/back

## When it appears

After the turn limit is exhausted without matching target, OR if an essential species goes extinct.

## Content

### Why they failed (specific reason)

Display the **specific failure reason**, not a generic "You failed." Examples:
- "You ran out of turns before reaching the target reef composition."
- "Madracis sp. went extinct. Essential species lost."
- "Turn limit reached. You were 4 away on Muricea pendula."

Keep it factual and brief. No shame language.

### Classification XP notice

Always show: **"You earned XP for classifying this reef image — even if the puzzle wasn't completed."**

This ensures players feel the citizen science contribution was valuable regardless of fail state. XP amount shown if XP system is active; if not, show the message as text acknowledgement only.

### Actions

- **Restart** — return to identify phase for this level (new Zooniverse anomaly)
- **Back** — return to world map

No "Continue" or "Next Level" option on fail screen.

## Technical

- Fail reason passed from `level_system.gd` as an enum or string: `fail_reason` (e.g. `"turns_exhausted"`, `"essential_extinct:madracis_sp"`)
- Template string lookup to convert reason to human-readable text
- XP for classification stored at identify phase completion (not at puzzle end) — confirm with inf01 task

## Design reference

See [docs/level-structure.md](../docs/level-structure.md) — "Fail Screen" section.
