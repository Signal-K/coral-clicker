---
id: v02breeding
title: "v0.2: Implement Strategic Breeding (Traits)"
status: done
priority: high
labels:
  - gameplay
  - simulation
  - breeding
createdAt: '2026-03-12T21:35:00Z'
updatedAt: '2026-03-12T21:35:00Z'
timeSpent: 0
---

# Implement Strategic Breeding (Traits)

## Description

Deepen the breeding action by adding inherited traits that affect environmental survival.

## Requirements

- **Inherited Traits:** E.g., "Cold-Resistant", "High-Salinity Pref", "Fast Breeder".
- Offspring have a 50% chance to inherit a trait from either parent.
- Environment matching: traits affect growth rates or nutrient consumption in extreme temperatures/salinities.
- Preview breeding results before finalizing.

## Technical Details

- Update `level_system.gd` to consider parent traits in `_pick_offspring_species`.
- Add `traits: Array[String]` to the organism model.
