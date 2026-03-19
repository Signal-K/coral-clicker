---
id: v02coins
title: "v0.2: Implement Persistent Coins"
status: done
priority: high
labels:
  - economy
  - database
  - storage
createdAt: '2026-03-12T21:21:00Z'
updatedAt: '2026-03-12T21:21:00Z'
timeSpent: 0
---

# Implement Persistent Coins

## Description

Coins earned in levels should persist across the entire game.

## Requirements

- Add a global "Coins" value to the player's profile/state.
- Coins are updated at the end of each level.
- Coins can be spent in the in-level shop for items (fish eggs).
- Ensure coins are saved to local storage/Supabase.

## Technical Notes

- Modify `app_controller.gd` to store `global_coins`.
- Implement `save_profile()` and `load_profile()` logic.
