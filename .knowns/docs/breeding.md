# Breeding System

## Auto-breeding

- Fires every **30–45s real-time** (randomised interval per event)
- **NEVER paused** — continues during results panel, shop, transitions
- Breeding is purely automatic in v0.1; no player-triggered breeding (mini-game deferred to v0.2)

## Egg lifecycle

1. Auto-breeding fires → egg sprite appears in reef viewport
2. Player **taps egg** to hatch it (hatch animation)
3. Player **drags hatched fish** to a reef zone → population +1

## Population cap & starvation

- Each level has a `population_cap` (defined in level JSON)
- When cap is exceeded: eggs still hatch BUT fish die from food shortage (insufficient nutrients)
- **Breeding does NOT stop when over cap**

### Starvation targeting

Death targets the **oldest fish that has been fed the latest** (least-recently-fed among the oldest). Not random.

### Starvation animation

1. Dying fish colour fades to grey
2. Death animation plays (species-specific)
3. Slow fade out at the end

## Trait system

### Root species traits

Every base species has **pre-determined fixed traits** grounded in real ecology (research required — see task-gp09traits). Traits are both beneficial and detrimental, reflecting real biology.

Examples by type (to be confirmed during research):
- `heat_tolerant` — survives Warm temperature without penalty
- `cold_specialist` — gains +1 in Cold; penalised in Warm
- `fast_breeder` — shorter breeding interval
- `urchin_predator` — actively reduces Longspine Sea Urchin stressor
- `algae_grazer` — controls algae (interacts with stony coral health)
- `heat_sensitive` — takes extra damage in Warm temperature
- `stony_coral_threat` — causes damage to stony corals (bad trait)
- `territory_marker` — reduces space for other fish when over pop 3

### Bred species traits

Fish bred from **two parent fish** (same or different species) inherit a mix of both parents' traits plus a chance for bonus traits:
- **Trait inheritance**: Mendelian-style probability from both parents
- **Bonus traits**: random chance to gain additional traits (good OR bad) beyond what was inherited
- **New species**: breeding two different species (or same species with divergent traits) produces a new named species

### New species

When a new species is created through breeding:
- **Player names the species** (custom input)
- **Future (2 sprints — 2026-03-31 reminder):** player customises faces/colours from a defined mix-and-match list for the new species
- New species inherits trait pool from both parents + potential new traits
- New species appears in the fish card strip under the player's chosen name

### Breeding preview dialog

Before confirming a breed pairing, the dialog shows:
- Trait odds for the potential offspring
- Whether a new species would result
- Inherited traits from each parent (highlighted)

## Stressor auto-breeding

Stressor species (Longspine Sea Urchin, overabundant Parrotfish) also auto-breed. Ignoring them compounds damage each turn.

## Technical

- Breeding interval set per level: `breeding_interval_min` / `breeding_interval_max` in `starter_levels.json`
- Egg sprites appear in reef viewport (not card strip)
- `AppController.tutorial_complete` — tutorial egg intro only shown once
