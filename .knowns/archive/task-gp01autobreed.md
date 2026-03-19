---
id: gp01autobreed
title: "Auto-breeding system (timed, visual, no button)"
status: done
priority: high
labels:
  - gameplay
  - animation
  - breeding
createdAt: '2026-03-15T00:00:00Z'
updatedAt: '2026-03-15T00:00:00Z'
---

# Auto-breeding system

Removes the "Breed" button. Breeding is now an automatic timed event visible in the reef viewport.

## Mechanic

- Every 30-45 seconds of real time (randomised per species), compatible fish pairs produce eggs
- An egg sprite appears in the reef viewport near the parent fish
- **Eggs do NOT auto-hatch.** The player must TAP the egg to trigger hatching, then DRAG the hatched fish to a reef zone
- If the player ignores an egg, it remains bobbing in the viewport until tapped
- **Population cap exceeded** → eggs STILL appear and can still be tapped. BUT, excess fish do not have enough food and some begin to die each turn (food shortage mechanic, not a hard block)
- **Breeding timer is never paused** — it continues running during the results panel, the shop, and identify phase transitions
- Players cannot trigger breeding manually, but can influence it by:
  - Buying more fish eggs with coins (shortcut: spawns an egg immediately in the viewport; same tap-to-hatch/drag flow)
  - Adjusting environment to favour the species' preferred conditions (faster breeding)

## Pre-breeding warning

- Before a breeding event fires (~3-5s before egg appears), the relevant fish sprites flash briefly
- Small animation on the parent fish pair (glow pulse or ripple effect) signals an egg is incoming

## Breeding eligibility

- A species breeds if: it has population ≥ 2, it is within env tolerance, AND a compatible partner exists
- Compatibility: same species (asexual by default), or inter-species pairs from `species_reference.json` interactions
- Stressor fish can also breed (and will grow if left unchecked)

## Coral growth stages (per-turn)

Coral growth on End Turn is staged, not instant. Visual stages per coral:
1. **Seed** — small dim sprite (20% opacity, 40% scale)
2. **Sprout** — slightly larger, colours slightly brighter
3. **Branch** — full scale, mid opacity
4. **Bloom** — full scale, full colour, small particle burst

Progress through stages driven by `_coral_population` ratio vs target. Each stage threshold: 25%, 50%, 75%, 100%.

## Sprites needed

- `egg_frame_00.png` through `egg_frame_07.png` — 248×248, glowing oval with embryo
- Add to `generate_sprites.py` as a new species entry or separate script
- Egg sprites are species-coloured (inherit primary colour from parent species)

## Animation

- Egg: small bobbing tween + gentle glow pulsing (AnimatedSprite2D)
- Hatching: scale burst + fade-in new fish sprite + egg disappears
- Population badge on fish card animates (+1 bounce) when hatch occurs

## Technical

- `level_system.gd`: add `_breeding_timers: Dictionary` (species → Timer node)
- On level start: spawn a Timer per eligible species, `wait_time = randf_range(30.0, 45.0)`. **Timer is never paused.**
- On timer fire: flash parent sprites for 3-5s (warning), then `_on_breeding_event(species)` → spawn EggNode in reef layer
- `EggNode.tscn` — AnimatedSprite2D; has an `Area2D` for tap detection
  - On tap: play hatch animation → emit `hatched(species)` signal → switch to drag mode
  - On drag release over valid zone: `_on_fish_placed(species, zone)` → population +1 in that zone
- Remove: `BreedButton`, `BreedRow`, `FishADisplay/FishBDisplay/FishCDisplay` from TopFlowBar (retire TopFlowBar entirely)

## Configuration

In `starter_levels.json` per level:
```json
"breeding_interval_min": 25,
"breeding_interval_max": 50,
"population_cap": 15
```
