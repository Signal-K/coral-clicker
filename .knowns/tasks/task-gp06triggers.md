---
id: gp06triggers
title: "Trigger system — per-turn action budget"
status: done
priority: high
labels:
  - gameplay
  - economy
  - ui
createdAt: '2026-03-17T00:00:00Z'
updatedAt: '2026-03-20T13:29:03Z'
---

# Trigger system — per-turn action budget

## What to build

A per-turn action budget ("triggers") that gates netting and environment changes.

## Core rules

- Each turn starts with **2 triggers** (plus any carryover from previous turns or level rewards)
- Each net use = 1 trigger consumed
- Each environment dial notch (salinity OR temperature) = 1 trigger consumed
- When triggers = 0: Net and environment dial buttons are greyed out

## UI changes

- Add trigger counter near Net button (e.g. "⚡ 2" or "Net 2/2")
- Counter decrements in real-time when actions are taken
- At 0: buttons grey out; add tooltip "No triggers remaining this turn"
- Counter resets visibly at turn start

## Ecological feedback loops

**Research required before implementation.**

When salinity changes, secondary ecological effects should trigger automatically (e.g. increased thermal stress, species population modifier). These cascade effects are the complexity payoff for the trigger system.

Research task: document 3–5 real positive/negative feedback loops in Caribbean reef ecology that can be represented as simple delta modifiers in the game engine. Add findings to [docs/triggers.md](../docs/triggers.md) and [docs/interactions.md](../docs/interactions.md).

## Earning extra triggers

- Completing level objective ahead of the par turn count → +1 trigger (awarded at level end)
- _Confirm what "par" means in context: is it the turn limit, or a separate target turn count per level?_

## Carryover triggers (level rewards)

- Unspent/earned triggers at level end can be awarded as a reward
- Stored in `AppController._carryover_triggers: int` (global, persistent)
- Displayed on Level End Screen alongside coins earned
- Spent at the start of any future level's turn (player's choice)

## Technical

- `_triggers_remaining: int` in `level_system.gd` — resets each turn start
- `_carryover_triggers: int` in `app_controller.gd` — persistent across sessions
- `_on_trigger_spent()` — shared handler called by both Net and env dial actions
- Update env dial cost handler to call `_on_trigger_spent()` alongside deducting coins

## Design reference

See [docs/triggers.md](../docs/triggers.md) for full system spec.
