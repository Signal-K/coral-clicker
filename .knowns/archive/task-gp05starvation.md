---
id: gp05starvation
title: "Starvation mechanic — death targeting and animation"
status: done
priority: medium
labels:
  - gameplay
  - animation
  - fish
createdAt: '2026-03-17T00:00:00Z'
updatedAt: '2026-03-20T00:00:00Z'
---

# Starvation mechanic — death targeting and animation

## When starvation triggers

When the reef population exceeds `population_cap` (defined per level in `starter_levels.json`), fish die from food shortage. Breeding does NOT stop; over-cap fish die each turn nutrients are insufficient.

## Death targeting

Death is **not random**. It targets the fish that is:
1. The **oldest** (placed earliest in the level), AND
2. Among ties: the one **fed least recently**

In practice: oldest fish that has been fed the latest dies first.

## Starvation animation sequence

1. Selected fish sprite **colour fades to grey** (desaturate over ~0.5s)
2. **Death animation plays** (species-specific — e.g. slow roll/sink, or freeze-frame tremor)
3. **Slow fade out** at the end (~1s alpha fade to transparent)
4. Fish removed from population count once fade completes

## Technical

- Track per-fish metadata: `placed_at_turn: int` and `last_fed_at_turn: int`
- Starvation check runs in `_advance_turn()` in `level_system.gd` after nutrient depletion
- Sort eligible fish: primary key = `placed_at_turn ASC`, secondary key = `last_fed_at_turn ASC`
- Animate using Godot AnimationPlayer (do not use GDScript tweens directly — keep with AnimationPlayer pattern)
- Population badge on species card updates after animation completes

## Design reference

See [docs/breeding.md](../docs/breeding.md) — "Population cap & starvation" section.
