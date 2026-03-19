---
id: v02tank
title: "v0.2: Implement The Tank (Sandbox Hub)"
status: done
priority: high
labels:
  - hub
  - idle
  - persistent
createdAt: '2026-03-12T21:30:00Z'
updatedAt: '2026-03-12T21:30:00Z'
timeSpent: 0
---

# The Tank (Sandbox Hub)

**Status: Specced for v0.1 (minimal); full idle + narrative in v0.2+**

## What it is

The Tank is a persistent sandbox level at **position 0 on the world map** — always unlocked, always accessible. It is the only place in the game with idle/passive mechanics. Puzzle levels (1–10) have no idle component.

## Core rules

- Fish and coral in The Tank are a **separate population** from puzzle level fish. Rewards (items/bonuses) earned from completing puzzle levels can be brought into The Tank or used in other levels, but fish themselves stay in their level of origin (Tank fish stay in the Tank; Level 3 fish stay in Level 3).
- The Tank generates resources **passively in real time** — resource accrual is calculated by time elapsed since last login (not session-based).
- Resource generation rate: TBD (suggest: 10 nutrients + 2 coins per hour; tune in v0.2)
- **Placement still costs resources** — The Tank is more relaxed than puzzle levels but not free. Standard nutrient costs apply.
- **Eventually unlimited in size** — long-term, the Tank can expand. For v0.1, use a fixed viewport size.

## Differences from puzzle levels

| Property | Puzzle Level | The Tank |
|---|---|---|
| Turn limit | Yes | No turns — free-form |
| Win condition | Yes — match reef target | No — open-ended |
| Idle resource gen | No | Yes — real-world time |
| Costs | Nutrients + Coins | Same, but more relaxed pacing |
| Fish/coral origin | Level-specific | Tank-specific |

## Narrative (deferred)

The Tank will eventually have a narrative framing (a personalised reef story, upgrades, named ecosystem). This is deferred to **3 sprints from 2026-03-16 (~2026-04-06)**. See `future/GEMINI_FUTURE.md` for the trigger.

## Technical

- Scene: `res://scenes/hub/the_tank.tscn`
- State saved to `user://save.json` under `tank_state`; synced to Supabase on reconnect
- Time-delta resource calc: `coins_earned = floor(seconds_offline / 3600) * coin_rate`
- Auto-breeding still fires in Tank (same 30-45s timer when app is open; time-delta calculation when closed)
