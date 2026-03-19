---
id: v01nutrients
title: "v0.1: Implement Nutrient system"
status: done
priority: medium
labels:
  - economy
  - level
createdAt: '2026-03-12T21:18:00Z'
updatedAt: '2026-03-12T21:18:00Z'
timeSpent: 0
---

# Implement Nutrient system

## Description

Replace "fishfood" with "Nutrients" as the level-local currency.

## Requirements

- Nutrients are earned by taking turns or as a starting pool.
- Nutrients are consumed for actions like feeding fish or placing coral.
- Nutrients do not persist between levels.
- Update UI labels from "Fishfood" to "Nutrients".

## Technical Notes

- Refactor `_fishfood_remaining` in `level_system.gd` to `_nutrients`.
- Update environment interactions to potentially consume/generate nutrients.
