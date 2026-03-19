---
id: v01repligoal
title: "v0.1: Update Win Condition to Replication Match"
status: done
priority: high
labels:
  - puzzle
  - level-win
createdAt: '2026-03-12T21:19:00Z'
updatedAt: '2026-03-12T21:19:00Z'
timeSpent: 0
---

# Update Win Condition to Replication Match

## Description

The player wins when their reef matches the makeup or layout identified in the Zooniverse image.

## Requirements

- Track the current "reef makeup" (species/counts) during gameplay.
- Compare with the "Goal" defined during the Identification phase.
- Win when the player's reef matches the goal within a certain threshold.
- Rewards based on how many turns it took (fewer turns = more coins).

## Technical Notes

- Replace `_coral_population >= _target_population` check with a makeup comparison.
- Implement a `_check_win_condition()` method.
