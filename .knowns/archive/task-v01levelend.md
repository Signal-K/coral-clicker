---
id: v01levelend
title: "v0.1: Create Level End screen"
status: done
priority: high
labels:
  - ui
  - ux
  - level-win
createdAt: '2026-03-12T21:20:00Z'
updatedAt: '2026-03-12T21:20:00Z'
timeSpent: 0
---

# Create Level End screen

## Description

A screen presented upon level completion showing performance and rewards.

## Requirements

- Show turns taken vs turn limit.
- Show coins earned (base + speed bonus).
- Side-by-side comparison: Zooniverse image vs. Player reef.
- Species "Unlocked" or "Discovered" section.
- "Next Level" and "Back to Home" buttons.
- (A) Sketch elements: turns, coins, comparison images, unlocked species summary.

## Technical Notes

- Create a new UI scene `scenes/ui/level_end_overlay.tscn`.
- Call from `_advance_turn()` when win condition met.
