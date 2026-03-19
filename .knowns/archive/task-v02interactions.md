---
id: v02interactions
title: "v0.2: Implement Organism Interactions (Kill/Aid)"
status: done
priority: medium
labels:
  - gameplay
  - simulation
createdAt: '2026-03-12T21:23:00Z'
updatedAt: '2026-03-12T21:23:00Z'
timeSpent: 0
---

# Implement Organism Interactions (Kill/Aid)

## Description

Refine how fish and coral interact beyond simple population growth.

## Requirements

- Certain fish species kill certain coral species (e.g., predator-prey).
- Certain fish species aid coral growth (e.g., cleaner fish).
- Species names only for now (no detailed stats).
- Visual feedback (e.g., particle effects or flashing) when interactions occur.
- Strategic depth: Use coral "A" to breed fish "X", then "X" kills "A" to make room for goal coral "B".

## Technical Notes

- Update `_compute_coral_delta()` to include species-specific interaction logic.
- Add interaction definitions to `data/species_reference.json`.
