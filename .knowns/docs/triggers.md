# Trigger System

Triggers are a **per-turn action budget** that gate high-impact player actions: netting fish and adjusting environment conditions.

## Starting budget

Players start each turn with **2 triggers**.

## What costs a trigger

| Action | Trigger cost |
|---|---|
| Net a fish (remove from reef) | 1 |
| Adjust salinity dial (per notch) | 1 |
| Adjust temperature dial (per notch) | 1 |

Feeding fish does NOT cost triggers. Triggers gate the strategic actions that have outsized effects on the reef.

## Visual feedback

- Remaining triggers shown as a counter near the Net button (e.g. "2 triggers" or "Net 2/2")
- When a trigger is spent: counter decrements immediately
- When triggers = 0: Net button and environment dial buttons are greyed out and non-interactive until next turn
- Counter resets at the start of each turn

## Ecological feedback loops (salinity changes)

Adjusting salinity does not just change one variable — it triggers real-world-inspired cascade effects. Research required before implementation: **positive and negative feedback loops in reef ecology**.

Known examples to implement:
- Raising salinity → may increase thermal stress on corals (temperature sensitivity up)
- Lowering salinity → reduces sponge and stony coral health (see interactions.md)
- Temperature changes → affect breeding interval speed

The mechanic means that using 1 trigger to adjust salinity may cause secondary changes that the player needs to account for — spending their remaining trigger(s) to compensate, or accepting the tradeoff.

## Earning extra triggers

### Completing steps before par

Finishing a level's puzzle (or completing a turn's objectives) before the par turn count earns **+1 trigger** for the next turn (or as a bonus resource at level end).

_Note: exact definition of "par" in this context to be confirmed — is it turn limit, or a target turn count per level?_

### Trigger rewards from level completion

When a level is completed, unspent or bonus triggers can be awarded as a **carryover reward**. The player can bank these and spend them in future levels (including The Tank).

- Awarded triggers persist across sessions (saved to global state)
- Used at player's discretion at the start of any turn in any level
- Shown on the Level End Screen alongside coins earned

## Economy relationship

Triggers are separate from coins and nutrients:

| Resource | Per | Used for |
|---|---|---|
| Nutrients | Level-local | Feed fish (drives breeding + pop growth) |
| Coins | Global persistent | Buy eggs from shop, adjust environment dials |
| Triggers | Per-turn (2 default) | Net fish, adjust environment dials |

Adjusting environment costs **both coins AND triggers** — the strategic tension is: do I spend the coin budget AND use up an action slot?

## Technical

- `_triggers_remaining` in `level_system.gd` — resets to 2 (plus any carryover) at each turn start
- `_carryover_triggers` in `AppController` — global persistent count
- `_on_trigger_spent()` — decrements counter, disables buttons if 0
- Trigger carryover award: part of level end reward calculation
