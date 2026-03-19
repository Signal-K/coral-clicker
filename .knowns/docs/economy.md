# Economy — Nutrients, Coins & Shop

## Resources

| Resource | Scope | Earned by | Spent on |
|---|---|---|---|
| Nutrients | Level-local, no carryover | Level start allotment | Feed fish; depletes to trigger turn end |
| Coins | Global, persistent | Level completion (base + speed bonus) | Fish eggs in shop; environment dials |
| Stars / Crystals | Hidden — data model only | — | Reserved for v0.3+ prestige system |

## Nutrients

- Set from `starting_nutrients` in level definition; no carryover between levels
- Depleted by feeding fish
- When nutrients = 0: turn ends automatically
- Used for: feeding fish (pop growth), NOT for environment dials
- Level variable: `_nutrients` in `level_system.gd`

## Coins

- Persistent across sessions; saved to Supabase in `metadata.global_coins` (column `rewards_total`)
- Earned at level end: `base_coins + speed_bonus` (see level-structure.md for formula)
- **Coins held until Supabase sync succeeds.** If offline, player sees "Reward pending sync" instead of coin total.
- Once synced: coins animate into resource bar

## Environment dials — cost COINS + TRIGGERS

Environment adjustments cost **coins** (not nutrients) AND consume a **trigger** (see [docs/triggers.md](triggers.md)).

- 3-position dial: Low / Medium / High (salinity) and Cold / Moderate / Warm (temperature)
- Interaction: **+/− buttons** step one notch at a time
- Each notch = **5 coins** (same as one fish egg — confirm before build)
- Each notch also consumes **1 trigger** from the turn's trigger budget
- If coins < 5: button shakes/flashes red; adjustment blocked
- If triggers exhausted: button greyed out; dial locked for this turn

## Shop (in-level)

Sliding panel. v0.1 items:

| Item | Cost | Effect |
|---|---|---|
| Fish Egg (per species) | 5 coins | Egg appears in viewport; hatches after short delay |
| ~~Nutrient Boost~~ | — | Removed for v0.1 |
| ~~Stressor Repellent~~ | — | Removed for v0.1 |
| ~~Coral Seed~~ | — | Removed for v0.1 |

- One-tap "buy egg" per species card if coins available
- Coin balance in resource bar updates immediately
- Purchased egg behaves identically to auto-bred egg

## Resource bar (BottomResourceBar.tscn)

```
[🌿 Nutrients: 24 ████░░]  [🪙 Coins: 148]  [Turn: 3/6]
```

- Nutrients: depleting bar + count
- Coins: count only (animated +N when earned)
- Turn counter: compact "3/6" format
- No Stars/Crystals visible in v0.1

## Technical

- `_nutrients` in `level_system.gd` (already exists)
- Remove `_bottom_coral_label` usage for shells/stars
- `_on_env_dial_changed(env_type: String, value: int)` — deducts coins
- `SHOP_FISH_EGG_COST = 5` (already set)
- Remove `SHOP_NUTRIENT_BOOST_COST`, `SHOP_STRESSOR_REPELLENT_COST`, `SHOP_CORAL_SEED_COST` for v0.1
