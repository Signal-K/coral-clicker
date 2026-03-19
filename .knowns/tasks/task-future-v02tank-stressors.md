---
id: future-v02tank-stressors
title: "REMINDER (2026-03-31): In-game stressors for The Tank"
status: future
priority: low
labels:
  - tank
  - gameplay
  - future
createdAt: '2026-03-17T00:00:00Z'
updatedAt: '2026-03-17T00:00:00Z'
---

# REMINDER: In-game stressors for The Tank

**Do not implement until 2026-03-31 sprint.**

## What this is

The Tank currently has no stressors (idle-only in v0.1). In 2 sprints, add a passive stressor mechanic to The Tank that:
- Occurs in-game while the player is in The Tank
- Does **NOT penalise the player when they're not in The Tank** (offline-safe — no punishment for being away)

## Key constraint

Stressors must be entirely passive and non-punishing for offline/away players. When a player returns to The Tank, the stressor state should be paused or capped — not compounded retroactively.

## Design questions to answer at trigger date

- What stressor types make sense for a personal sandbox Tank?
- How does the player deal with/dismiss stressors?
- How does stressor severity scale with Tank size/population?
- How does this interact with the Tank's idle coin generation?

Trigger date: **2026-03-31** (2 sprints from 2026-03-17).

See also: [docs/world-progression.md](../docs/world-progression.md) — "The Tank" section.
