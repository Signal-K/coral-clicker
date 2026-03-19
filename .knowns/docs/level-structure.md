# Level Structure & Game Loop

## Core loop (single level)

```
World Map → select level
  → Identify Phase (citizen science — see identify-phase.md)
  → Puzzle Phase (turns)
  → Win: Results Panel → Level End Screen → World Map
  → Fail: Results Panel → Fail Screen → Restart
```

## Puzzle Phase — turns

- Player starts with nutrients + fish from level definition
- Auto-breeding fires every 30–45s real-time (NEVER paused — not during results, shop, or transitions)
- **Turn ends when:** nutrients hit 0 OR player presses End Turn manually
- End Turn → coral grows/dies based on interactions → Results Panel (blocks all input until Continue)
- Results Panel shows before any win/fail screen; no early dismiss

## Win condition

Reef matches target composition (target coral species × target population).

## Fail condition

Turn limit exhausted without matching target. No partial coins. No soft failure. Must restart.

## Results Panel

Appears after every turn end. Blocks input until Continue is tapped.

Shows:
- **Per-species population vs target** — for every fish and coral species in the level: current population / target (e.g. "Madracis sp. 4 / 8", "Blue Chromis 3 / 5"). Target is what the player identified in the identify phase.
- **Turns remaining** — steps left before turn limit (e.g. "3 turns remaining")

## Level End Screen

Shown after win. Contains:
- Turns taken vs limit
- Coins earned (base + speed bonus breakdown)
- Zooniverse image vs player reef side-by-side
- If replaying: gallery of ALL images seen for that level (all previous subject images)
- Next Level + Home buttons

## Fail Screen

Shown after fail. Contains:
- **Why they failed** — specific reason (e.g. "Turn limit reached", "Essential species extinct: Madracis sp.")
- **Restart** button — replay from the identify phase
- **Back** button — return to world map
- **XP notice** — player is shown they DID earn XP for their initial reef classification, regardless of failing the puzzle

## Coin reward formula

```
base_coins = level_number × 10
speed_bonus = max(0, (turn_limit − turns_used) × 5)
total = base_coins + speed_bonus
```

Level 1 max: 10 + (8−1)×5 = 45 coins
Level 10 max: 100 + (4−1)×5 = 115 coins
Tutorial (Level 0): flat 20 coins, no speed bonus

## Difficulty curve — mechanic introduction schedule

| Level | New mechanic | Turns | Species count | Stressors |
|---|---|---|---|---|
| 0 | Tutorial — no fail, scripted, no stressors | 10 (soft) | 2 | 0 |
| 1 | Identify + replicate 1 coral | 8 | 2 | 0 |
| 2 | Replicate 2 corals, basic environment | 7 | 3 | 0 |
| 3 | Environment matters (cold-preferring species) | 7 | 4 | 0 |
| 4 | First stressor — tooltip on first encounter | 6 | 5 | 1 |
| 5 | Stressor + environment mismatch | 6 | 5 | 1 |
| 6 | Two competing corals — must kill one | 6 | 6 | 2 |
| 7 | Salinity + temperature both matter | 5 | 6 | 2 |
| 8 | Tight turns, large target population | 5 | 7 | 2 |
| 9 | Stressor that spreads each turn | 5 | 7 | 3 |
| 10 | Full complexity | 4 | 8 | 3 |

## "Kill a coral" puzzle mechanic (Level 6+)

Some levels require a coral to be present during the level but absent from the final reef.

Strategy:
1. Grow helper coral (e.g. Sponge) to attract the fish you need (e.g. French Angelfish)
2. Use that fish to boost other corals toward target
3. Use Parrotfish or stressor to eliminate the helper coral
4. Net the Parrotfish once helper is gone
5. Win with target composition only

## Stressor introduction (Level 4)

On first stressor encounter in Level 4: tooltip appears **mid-cycle** (before damage is applied). It shows both:
- A **warning** explaining that the stressor is present
- A **hint at the counter** (how to reduce/remove the stressor)

The tooltip appears again after the turn resolves so the player sees the effect.

## Extinct species

- A species card goes grey when population = 0
- Tapping a grey card shows an **"Extinct"** label
- **If an essential species goes extinct** (i.e. a species the player identified in the source image), **the level ends immediately** — this is treated as a fail condition
- Non-essential species extinction does not end the level (card stays grey, informational only)

## Technical

- Turn logic: `_advance_turn()` in `level_system.gd` — apply interactions before showing results panel
- Level definitions: `project/data/starter_levels.json`
- Level entry shape: see [content/levels.md](../content/levels.md)
