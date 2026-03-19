---
id: gp02turnresults
title: "Turn results panel"
status: done
priority: medium
labels:
  - ui
  - gameplay
  - feedback
createdAt: '2026-03-15T00:00:00Z'
updatedAt: '2026-03-15T00:00:00Z'
---

# Turn results panel

A brief results panel shown after each turn ends, before the next turn begins.

## Turn end triggers (either condition)

1. **Nutrients hit 0** — turn ends automatically
2. **Player presses End Turn manually** — turn ends immediately

Both paths lead to the same results panel flow.

## Content

```
┌─────────────────────────────────┐
│  Turn 3 of 6 — Results          │
│  ─────────────────────────────  │
│  🪸 Madracis Sp.   +3 pop  ↑    │
│  🐟 Parrotfish     +1 pop  →    │
│  ⚠️  Longspine Urchin -1 pop ↓  │
│  ─────────────────────────────  │
│  Nutrients used: 4              │
│  Reef health: ████░░  72%       │
│  ─────────────────────────────  │
│         [Continue]              │
└─────────────────────────────────┘
```

## Rules

- Shows delta (change) for every species population that changed this turn
- Shows nutrients consumed
- Shows reef health % (coral_population / target_population)
- Stays visible until player taps "Continue" (no auto-dismiss)
- Animate rows in sequentially (stagger 150ms per row)
- Green text for positive changes; red for negative; grey for no change

## Win check

- If reef health reaches 100% AND turn ends → show Level End screen instead of this panel
- If turns run out (this was the last turn) AND not at 100% → show Fail screen instead

## Technical

- Scene: `scenes/ui/TurnResultsPanel.tscn` — slides up from bottom
- Called from `level_system.gd` at end of `_advance_turn()`
- Data: pass a Dictionary of `{species: delta}` + nutrients_used + reef_ratio
- `Continue` signal → `_on_results_dismissed()` → start next turn timers, re-enable actions
