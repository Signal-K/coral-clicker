---
id: gp04levels
title: "10-level content design & difficulty curve"
status: todo
priority: high
labels:
  - content
  - gameplay
  - levels
createdAt: '2026-03-15T00:00:00Z'
updatedAt: '2026-03-15T00:00:00Z'
---

# 10-level content design

## Level 0 — Tutorial Mission

Level 0 is a hand-crafted tutorial, NOT based on a Zooniverse image. It teaches the full flow before any real citizen science begins.

See `task-tutorial-level0.md` for full spec.

Short summary:
- Walks player through: identify phase → placing fish → end turn → coral growth → win
- Tutorial overlays explain each action the first time it appears
- Stressors introduced via tooltip on first encounter (Level 4+)
- Fixed composition (no random image) — scripted for clarity

## Levels 1–10 — Geographic Difficulty Curve

Each level is themed to a REAL reef site based on where the featured species actually live. See `reef-sites-geography.md` for location research.

Each level introduces one new challenge mechanic on top of the last.

| Level | Name | Geographic Site | New mechanic | Turns | Species count | Stressor |
|---|---|---|---|---|---|---|
| 1 | Nursery Reef | Florida Keys, USA | Identify + replicate 1 coral | 8 | 2 (1 coral, 1 fish) | None |
| 2 | Shallow Flats | Belize Barrier Reef | Replicate 2 corals, basic environment | 7 | 3 | None |
| 3 | Branching Garden | Cayman Islands | Environment matters (one species prefers cold) | 7 | 4 | None |
| 4 | The Ledge | Bahamas | First stressor — tooltip shown on first encounter | 6 | 5 | 1 stressor |
| 5 | Coral Nursery | Turks & Caicos | Stressor + environment mismatch | 6 | 5 | 1 stressor |
| 6 | Overgrowth | Bonaire | Two competing corals — one you must kill | 6 | 6 | 2 stressors |
| 7 | Mid-Water Column | Curaçao | Salinity & temperature both matter | 5 | 6 | 2 stressors |
| 8 | The Deep Wall | Los Roques, Venezuela | Tight turn limit, large target population | 5 | 7 | 2 stressors |
| 9 | Bleaching Event | Fernando de Noronha, Brazil | Stressor that spreads each turn | 5 | 7 | 3 stressors |
| 10 | The Reef Summit | Trinidad & Tobago | Full complexity, multiple corals, max stressors | 4 | 8 | 3 stressors |

## "Kill a coral" mechanic (Level 6+)

Some levels require the player to have a coral in the tank (to breed supporting fish) but NOT have it in the final reef. Strategy: grow the helper coral, get the fish you need, then let stressors kill it off. This is the key emergent puzzle mechanic.

## Stressor definition

- Stressor species kill certain corals by -1 to -2 pop per turn
- Counter: net the stressor (subject to net use limit; see ui03fishcards.md), or use a fish that aids that coral type
- Stressor fish also breed automatically — so ignoring them compounds the problem
- All kill/aid species interaction mappings live in `species-interactions.md`
- When player encounters a stressor for the FIRST TIME in Level 4, show a tooltip explaining the mechanic
- Levels have NO narrative framing per-level; sandbox level narrative comes later (deferred 3 sprints)

## Coin reward formula

```
base_coins = level_number * 10
speed_bonus = max(0, (turn_limit - turns_used) * 5)
total = base_coins + speed_bonus
```

Level 1 max coins: 10 + (8-1)*5 = 45. Level 10 max coins: 100 + (4-1)*5 = 115.

## Technical: update starter_levels.json

Each level entry must have:
```json
{
  "level": 4,
  "name": "The Ledge",
  "target_coral": ["madracis_sp", "thesea_nivea"],
  "target_population": 10,
  "turn_limit": 6,
  "starting_nutrients": 30,
  "positive_fish": ["blue_chromis", "sergeant_major"],
  "negative_fish": ["longspine_sea_urchin"],
  "starting_fish": {"blue_chromis": 2},
  "reward_coins": 40,
  "breeding_interval_min": 25,
  "breeding_interval_max": 50,
  "population_cap": 15,
  "subject_id": "12345678"
}
```

- `subject_id` must map to a real entry in `click_a_coral_subjects.json`
- Assign real subject images to each level (hand-curated from the dataset)
