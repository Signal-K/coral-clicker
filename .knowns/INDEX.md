# Coral Clicker — Knowledge Index

_Last updated: 2026-03-17_

Game: relaxed puzzle + citizen science. Identify reef in Zooniverse photo → replicate it with fish breeding & environment controls. 10 levels + Tank hub. Mobile-first Godot PWA.

---

## Docs (how things work)

| Doc | Contents |
|---|---|
| [docs/level-structure.md](docs/level-structure.md) | Core loop, turns, win/fail, results panel, coin formula, difficulty curve |
| [docs/economy.md](docs/economy.md) | Nutrients, Coins, environment dials, shop, resource bar |
| [docs/breeding.md](docs/breeding.md) | Auto-breeding timer, egg lifecycle, traits, population cap / starvation |
| [docs/interactions.md](docs/interactions.md) | All kill/aid mappings: fish↔coral, environment↔species, stressors |
| [docs/identify-phase.md](docs/identify-phase.md) | Identify phase flow, citizen science queue, offline, classification accuracy |
| [docs/ui-layout.md](docs/ui-layout.md) | Mobile-first constraints, card strip, viewport, HUD, palette |
| [docs/world-progression.md](docs/world-progression.md) | World map, linear unlock, Tank hub, reef sites, replay gallery |
| [docs/triggers.md](docs/triggers.md) | Per-turn trigger budget: net uses, env dial cost, carryover, feedback loops |

## Content (what's in the game)

| Doc | Contents |
|---|---|
| [content/levels.md](content/levels.md) | All 10 levels + tutorial: targets, turns, species, rewards |
| [content/species.md](content/species.md) | Species list with ecological ranges and distribution |

## Backlog

| Doc | Contents |
|---|---|
| [backlog/active.md](backlog/active.md) | TODO tasks for current sprint (gp03, gp04, sp02, inf01, tutorial) |
| [backlog/future.md](backlog/future.md) | Deferred: v0.2+ features, trigger dates, open design questions |

## Archive

Completed task files → [archive/](archive/) (do not load unless debugging past decisions)

---

## Key source files

| File | Role |
|---|---|
| `project/app_controller.gd` | Global autoload: state, Supabase sync, coins, Tank |
| `project/level_system.gd` | Main gameplay (1836 lines) |
| `project/home_screen.gd` | Level select + coins display |
| `project/data/starter_levels.json` | 10 level definitions |
| `project/data/species_reference.json` | Species specs, interactions, traits |
| `project/data/click_a_coral_subjects.json` | Zooniverse image entries |

## Field name reference

| Field | Notes |
|---|---|
| `starting_nutrients` | was `starting_fishfood` |
| `reward_coins` | was `reward_fishfood` |
| `global_coins` | was `rewards_total + carryover_fishfood` |
| `current_level_available_nutrients` | was `current_level_available_fishfood` |
| Supabase col `rewards_total` | = `global_coins` for backward compat |
