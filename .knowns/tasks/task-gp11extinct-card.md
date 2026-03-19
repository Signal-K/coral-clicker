---
id: gp11extinct-card
title: "Extinct card — tap behaviour and essential species level end"
status: todo
priority: medium
labels:
  - gameplay
  - ui
createdAt: '2026-03-17T00:00:00Z'
updatedAt: '2026-03-17T00:00:00Z'
---

# Extinct card — tap behaviour and essential species level end

## Extinct card state

When a species' population reaches 0:
- Card turns **grey** (desaturated)
- Tapping the grey card shows a brief **"Extinct"** label (e.g. a small tooltip or overlay on the card)
- Card is otherwise inert — no Feed/Net actions available, no revive possible

## Essential species extinction → level end

A species is "essential" if the player **identified it** in the identify phase (it was in their classification of the reef image).

If an essential species goes extinct mid-level:
- Level **ends immediately** (not at the end of the turn)
- Fail screen shows with reason: `"[Species Name] went extinct. Essential species lost."`

Non-essential species (ones the player didn't identify, or stressor species) can go extinct without ending the level.

## Technical

- `_essential_species: Array` built from the player's identify phase response at level start
- Check in `_advance_turn()` and also on each population decrement: if any essential species hits pop 0, fire `_on_essential_extinct(species_id)`
- `_on_essential_extinct()` triggers fail state with `fail_reason = "essential_extinct:" + species_id`
- Grey card state: add `is_extinct: bool` per species card; disable tap interactions except for the "Extinct" tooltip
- "Extinct" tooltip: brief 1s label pop near the card, or a persistent label overlay while card is grey

## Design reference

See [docs/level-structure.md](../docs/level-structure.md) — "Extinct species" section.
See [docs/ui-layout.md](../docs/ui-layout.md) — "Fish card strip" section.
