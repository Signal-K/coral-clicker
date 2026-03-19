---
id: gp03resources
title: "Resource system simplification"
status: todo
priority: medium
labels:
  - gameplay
  - economy
  - ui
createdAt: '2026-03-15T00:00:00Z'
updatedAt: '2026-03-15T00:00:00Z'
---

# Resource system simplification

## Active resources (v0.1)

| Resource | Scope | Earned by | Spent on |
|---|---|---|---|
| Nutrients | Level-local | Level start allotment | Feed fish (+pop), adjust environment |
| Coins | Global (persists across game) | Completing levels (fewer turns = more) | Buy fish eggs mid-level |

## Hidden resources (defer to v0.3)

Stars and Crystals remain in the data model but are NOT shown in any UI. Remove from:
- `BottomResourceBar.tscn` — show only Nutrients + Coins
- Any labels referencing shells/stars/crystals in `level_system.gd`

## Environment adjustment cost

**Environment dials do NOT cost nutrients.** Salinity and temperature are physical conditions — adjusting them has no bearing on the food supply. They cost **COINS** instead (global currency).

Rationale: In the real world, managing water conditions requires equipment/investment, not food. This creates a strategic tension: spend coins on fish eggs or on environmental tuning?

- Each dial notch costs **5 coins** (same as a fish egg — suggested; confirm before build)
- Players cannot adjust if coins < 5. Visual feedback: button shakes/flashes red
- Remove +/- buttons; replace with a 3-position dial: Low / Medium / High
  - Salinity: Low / Medium / High
  - Temperature: Cold / Moderate / Warm
  - One click = one notch = 5 coins

## Water conditions HUD

A persistent indicator is always visible on the reef viewport (not just in the adjustment UI). Suggested: small thermometer + salinity droplet in the corner of the viewport, updated in real-time when dials change.

## Fish egg purchase (in-level shop)

- One-tap "buy egg" button per species card (if coins available)
- Cost: 5 coins per egg (constant for v0.1; species-variable in v0.2)
- Egg appears in reef viewport (same as auto-bred egg), hatches after short delay
- Coin balance shown in resource bar updates immediately

## Technical changes in level_system.gd

- `_nutrients` variable stays, already exists
- Remove `_bottom_coral_label` usage for shells/stars
- Add `_on_env_dial_changed(env_type: String, value: int)` → costs 2 nutrients
- Rename `SHOP_FISH_EGG_COST` → 5 (already correct)
- Remove `SHOP_NUTRIENT_BOOST_COST`, `SHOP_STRESSOR_REPELLENT_COST`, `SHOP_CORAL_SEED_COST` for v0.1

## BottomResourceBar layout

The bar must show everything without being overwhelming. Suggested layout:

```
[🌿 Nutrients: 24 ████░░]  [🪙 Coins: 148]  [Turn: 3/6]
```

- Nutrients: depleting bar + count
- Coins: count only (animated +N when earned)
- Turn counter: compact "3/6" format, not a dramatic clock
- No other resources visible in v0.1 (Stars/Crystals stay hidden)
