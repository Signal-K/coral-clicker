---
id: ui03fishcards
title: "Fish card selection system"
status: todo
priority: high
labels:
  - ui
  - gameplay
  - fish
createdAt: '2026-03-15T00:00:00Z'
updatedAt: '2026-03-15T00:00:00Z'
---

# Fish card selection system

Replaces the current Feed (+) / Net (−) row list with a tactile card-based interface.

## Card anatomy (per species)

```
┌──────────────┐
│  [248px anim]│  ← animated sprite (small: 72px display)
│  Blue Chromis│  ← species name
│  Pop: 12     │  ← current population badge
│  ▲ ▼        │  ← feed / net tap zones (large touch targets)
│  [trait chip]│  ← e.g. "Algae Control" (v0.2 traits)
└──────────────┘
```

## Interaction

- Cards live in a **horizontal scrolling strip** at the bottom of the game screen
- Tap card = select it (expands)
- **Feed and Net actions appear as OVERLAY ICONS on the reef viewport**, not inside the card. Selected card highlights; overlay icons appear over the matching fish sprites in the reef.
- Feed (▲) = +1 population (costs nutrients)
- Net (▼) = removes fish from reef entirely (not moved to Tank — just removed)
- Positive fish cards have a green glow border; negative/stressor fish have red
- Neutral fish: no colour tint

## Net restrictor

Netting is powerful (especially for removing stressors) so it must be limited:
- Maximum **2 net actions per turn** across all species combined
- Visual: net icon greyed out with "0 remaining" badge once limit is reached
- Resets at start of each new turn
- (Exact limit TBD — may become configurable per level in starter_levels.json)

## Card states

| State | Visual |
|---|---|
| Normal | Compact, scrollable |
| Selected | Expanded; overlay icons appear on reef viewport |
| Extinct (pop = 0) | Greyed out, "EXTINCT" label, no actions — permanent for this level, no revive |
| Maxed | Pop badge pulses red; Feed disabled |

## Technical

- Scene: `scenes/ui/FishCard.tscn` — standalone card component
- Strip: `scenes/layout/FishCardStrip.tscn` — HScrollContainer holding cards
- `level_system.gd`: replace `_refresh_fish_rows()` with `_refresh_fish_cards()`
- One card per unique species in the level; card order = positive fish first, then negative
- Cards are created dynamically when level starts, destroyed on level end

## Fish population badge

- Number shown on card corner
- Colour: green if positive-fish species, red if stressor
- Badge animates (bounce) when population changes
