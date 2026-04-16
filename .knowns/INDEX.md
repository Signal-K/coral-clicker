# Coral Clicker — Knowledge Index

_Last updated: 2026-04-23_

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
| [docs/mvp-audit-2026-04-11.md](docs/mvp-audit-2026-04-11.md) | Current-state audit, MVP blockers, UX ratings, and recommended sprint shape |
| [docs/world-progression.md](docs/world-progression.md) | World map, linear unlock, Tank hub, reef sites, replay gallery |
| [docs/world-progression-v2.md](docs/world-progression-v2.md) | **Agreed v2 direction**: location-based structure, daily events, tutorial restructure, species field guide |
| [docs/triggers.md](docs/triggers.md) | Per-turn trigger budget: net uses, env dial cost, carryover, feedback loops |

## Content (what's in the game)

| Doc | Contents |
|---|---|
| [content/levels.md](content/levels.md) | All 10 levels + tutorial: targets, turns, species, rewards |
| [content/species.md](content/species.md) | Species list with ecological ranges and distribution |

## Backlog

| Doc | Contents |
|---|---|
| [backlog/active.md](backlog/active.md) | MVP sprint — 14 tasks in priority order: pwa01 → content-levels → identify-mandatory → gp07 → gp03 → gp06 → gp05 → gp08 → gp10 → tutorial → tank-mvp → inf01 → sp02 → qa-tour |
| [backlog/future.md](backlog/future.md) | Deferred: v0.2+ (traits/gp09, breeding mini-game, custom species, Tank narrative), v0.3 Zooniverse consensus, v0.4+ leaderboards/co-op |

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
