# Level Definitions

_Source of truth: `project/data/starter_levels.json`_
_Geographic context: [docs/world-progression.md](../docs/world-progression.md)_
_Mechanic context: [docs/level-structure.md](../docs/level-structure.md)_

## Level 0 — Tutorial (The Nursery)

| Property | Value |
|---|---|
| Target coral | Madracis sp. × 4 |
| Starting fish | Blue Chromis × 2 |
| Starting nutrients | 40 (generous) |
| Turn limit | 10 (soft — no fail state) |
| Stressors | None |
| Subject image | Placeholder / hand-drawn |
| Coins reward | 20 (flat; no speed bonus) |
| Special flags | `is_tutorial: true`; identifies phase uses only 2 chips; no real classification |

Tutorial sequence: Identify → Reef intro → Feed fish → End Turn → Results → Auto-breed egg → Win. Full step spec in archive (`task-tutorial-level0.md`).

## Levels 1–10 — Puzzle Levels

| Level | Name | Site | Target Coral | Pop. | Turns | Nutrients | Stressors | Reward (base) |
|---|---|---|---|---|---|---|---|---|
| 1 | Nursery Reef | Florida Keys | Madracis sp. | 8 | 8 | 12 | None | 10c |
| 2 | Shallow Flats | Belize | TBD | TBD | 7 | TBD | None | 20c |
| 3 | Branching Garden | Cayman Is. | TBD | TBD | 7 | TBD | None | 30c |
| 4 | The Ledge | Bahamas | Madracis sp. + Thesea nivea | 10 | 6 | 30 | Longspine Sea Urchin | 40c |
| 5 | Coral Nursery | Turks & Caicos | TBD | TBD | 6 | TBD | 1 | 50c |
| 6 | Overgrowth | Bonaire | TBD | TBD | 6 | TBD | 2 | 60c |
| 7 | Mid-Water Column | Curaçao | TBD | TBD | 5 | TBD | 2 | 70c |
| 8 | The Deep Wall | Los Roques | TBD | TBD | 5 | TBD | 2 | 80c |
| 9 | Bleaching Event | Fernando de Noronha | TBD | TBD | 5 | TBD | 3 | 90c |
| 10 | The Reef Summit | Trinidad & Tobago | TBD | TBD | 4 | TBD | 3 | 100c |

Levels 2–3, 5–10 targets are TBD — awaiting task-gp04levels content design (see backlog/active.md).

## JSON entry shape (starter_levels.json)

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
  "starting_fish": { "blue_chromis": 2 },
  "reward_coins": 40,
  "breeding_interval_min": 25,
  "breeding_interval_max": 50,
  "population_cap": 15,
  "subject_id": "12345678",
  "is_tutorial": false
}
```

`subject_id` must map to a real entry in `click_a_coral_subjects.json`.
