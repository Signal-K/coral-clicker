# Coral Clicker — Agent Context

Relaxed puzzle game (Godot 4.5 + mobile PWA). Player identifies coral in Zooniverse reef photos, then replicates that reef composition using fish breeding and environment controls. 10 puzzle levels + Tank sandbox hub. Citizen science data feeds back to Zooniverse.

## Start here

→ `.knowns/INDEX.md` — master index of all behaviour/content docs and key source files
→ `.knowns/archive/MASTERPLAN.md` — full vision and settled design decisions

## Key docs

| Doc | What's in it |
|---|---|
| `.knowns/docs/level-structure.md` | Core loop, turns, win/fail, difficulty curve |
| `.knowns/docs/economy.md` | Nutrients, coins, environment dials |
| `.knowns/docs/breeding.md` | Auto-breeding, eggs, starvation, traits |
| `.knowns/docs/interactions.md` | All kill/aid mappings (authoritative) |
| `.knowns/docs/identify-phase.md` | Pre-level citizen science phase |
| `.knowns/docs/ui-layout.md` | Mobile UI layout, palette, tap targets |
| `.knowns/docs/world-progression.md` | World map, Tank hub, level unlock |
| `.knowns/content/levels.md` | All 10 level definitions |
| `.knowns/content/species.md` | Species list + ecological ranges |
| `.knowns/backlog/active.md` | Current sprint TODO tasks |
| `.knowns/backlog/future.md` | Deferred v0.2+ features + triggers |

## Key source files

| File | Role |
|---|---|
| `project/app_controller.gd` | Global autoload: state, Supabase sync, coins, Tank |
| `project/level_system.gd` | Main gameplay scene (~1830 lines) |
| `project/home_screen.gd` | Level select + coins display |
| `project/data/starter_levels.json` | 10 level definitions |
| `project/data/species_reference.json` | Species specs, interactions, traits |
| `project/data/click_a_coral_subjects.json` | Zooniverse image entries |

## Tech stack

- **Godot 4.5** (GDScript) — game engine + PWA export
- **React Native** — mobile host (RTNGodot bridge in `App.tsx`)
- **Next.js** — web host (`web/app/page.tsx`)
- **Supabase** — player progress + offline classification queue (local Docker: `http://127.0.0.1:54321`)

## Kanban board

The sprint board runs at **http://localhost:4444** (Star Sailors · My Board).

**Before reading the board or planning creative work, always read:**
- `/Users/scroobz/Navigation/Native/planet-hunters-experiment-1/.knowns/docs/dev/creative/creative-tasks-what-they-are-and-why.md`

This file explains what creative tasks are, why they exist, which tasks are open across Coral and Planet Hunters, how to hand off copy, and what format output should take. Creative tasks block implementation tickets — do not skip this context.

## Architecture notes

- `AppController` is Godot autoload at `/root/AppController`
- State flows: `AppController.state → _sanitized_state() → JSON → level_progress_changed signal → level_system.gd`
- All new UI built programmatically in GDScript — no `.tscn` edits needed for new features
- Field renames: `starting_nutrients` (was `starting_fishfood`), `reward_coins` (was `reward_fishfood`), `global_coins` (was `rewards_total + carryover_fishfood`)
- Supabase column `rewards_total` = `global_coins` (backward compat)

## Design decisions (settled — do not re-litigate)

- Identify phase IS the level gateway — not a tutorial, not skippable as a whole (only individual species)
- Level target = pre-curated data from `starter_levels.json` — player's identify guess is citizen science, not puzzle input
- Breeding is automatic (30–45s); eggs spawn in viewport; player taps to hatch, drags to zone
- Population cap exceeded → eggs still hatch, oldest/least-fed fish starve; breeding never stops
- Species at population 0 = extinct; card goes grey; if essential species → immediate level fail
- Environment dials cost COINS (not nutrients)
- Results panel blocks input until dismissed
- Fail = restart, no partial coins
- Offline coins held until Supabase sync
