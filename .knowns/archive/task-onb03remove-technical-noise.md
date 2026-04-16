---
id: onb03-remove-technical-noise
title: "Remove technical/backend noise from first-run play"
status: done
priority: urgent
labels:
  - onboarding
  - ux
  - polish
createdAt: '2026-03-20T00:00:00Z'
updatedAt: '2026-03-20T08:30:00Z'
---

# Remove technical/backend noise from first-run play

## Problem

The first-time-player flow still exposes raw technical state in player-facing screens.

Observed examples:
- `Supabase request failed` appearing during tutorial play
- `Reward pending sync` language on the first win screen
- other backend/sync wording leaking into what should read like game UI

## Why this is urgent

For a new player, this reads as "the game is broken" before they have even learned the loop.
It directly undermines the game-first positioning.

## Required outcome

- No backend, sync, Supabase, offline, or request-failure language appears during tutorial or first-win UX
- Player-facing copy should stay inside the fiction of the game
- If there is a real sync failure, it must be handled silently or deferred to a non-blocking, non-onboarding surface

## Acceptance notes

- Play from fresh save through first tutorial win
- No technical error banner appears
- No reward/sync jargon appears in tutorial, results, or first win modal
