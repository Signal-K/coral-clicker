---
id: gp07results-panel
title: "Results panel — per-species population vs target"
status: done
priority: high
labels:
  - gameplay
  - ui
createdAt: '2026-03-17T00:00:00Z'
updatedAt: '2026-03-20T00:00:00Z'
---

# Results panel — per-species population vs target

## When it appears

After every turn end (nutrients hit 0 OR player presses End Turn). Blocks all input until the player taps Continue.

## Content

### Per-species rows
For every fish and coral species in the level, show:

```
[species icon] [Species Name]   [current pop] / [target pop]
```

Example:
```
🐟 Blue Chromis          3 / 5
🐠 Parrotfish            1 / 0   ← over target (or unwanted)
🪸 Madracis sp.          4 / 8
🪸 Muricea pendula       2 / 3
```

The target is what the player identified in the identify phase (pre-curated from the level definition).

### Turns remaining

Below the species list:
```
3 turns remaining
```

Or "Last turn" if this was the final turn.

## What NOT to show

- No "+N / −N" delta from previous turn (keep it simple for v0.1)
- No summary "Your reef grew by 3" line
- No before/after animation or visual diff

## Design notes

- Panel should be scrollable if species count is large (Levels 8–10 have 7–8 species)
- Continue button anchored at bottom, always visible without scrolling
- Species at target (or over target when target is 0) could be highlighted green; below target = neutral

## Technical

- Panel built in GDScript (no `.tscn` edit needed — see ui-layout.md pattern)
- Data from `level_system.gd`: `_current_populations: Dictionary` and level's `target_populations`
- Target populations derived from identify phase answer + level definition

## Design reference

See [docs/level-structure.md](../docs/level-structure.md) — "Results Panel" section.
