# Coral Clicker — Project Memory

## What this project is
Relaxed puzzle game (Godot 4.5 + React Native PWA). Player identifies coral in Zooniverse images, then replicates the reef makeup using fish breeding & environment controls. 10 levels + Tank hub. v0.1 + v0.2 features implemented as of 2026-03-15.

## Stack
- **Game engine**: Godot 4.5, GDScript, `res://` paths
- **Mobile host**: React Native (RTNGodot bridge) in App.tsx
- **Web host**: Next.js in web/app/page.tsx
- **DB**: Supabase (local Docker: http://127.0.0.1:54321)
- **Build**: Docker Compose, Makefile

## Docs (start here)

→ `.knowns/INDEX.md` — master index of all behaviour/content docs

Key docs:
- `.knowns/docs/level-structure.md` — core loop, turns, win/fail, difficulty curve
- `.knowns/docs/economy.md` — nutrients, coins, shop, environment cost
- `.knowns/docs/breeding.md` — auto-breeding, eggs, starvation
- `.knowns/docs/interactions.md` — all kill/aid mappings
- `.knowns/docs/identify-phase.md` — citizen science phase
- `.knowns/docs/ui-layout.md` — mobile UI, card strip, HUD
- `.knowns/docs/world-progression.md` — world map, Tank, unlock
- `.knowns/content/levels.md` — all level definitions
- `.knowns/content/species.md` — species list + ranges
- `.knowns/backlog/active.md` — TODO tasks + open design questions
- `.knowns/backlog/future.md` — deferred v0.2+ features

## Key files
- `project/app_controller.gd` — global autoload singleton, state, Supabase sync, coins, tank
- `project/level_system.gd` — main gameplay scene (1836 lines)
- `project/home_screen.gd` — level select + coins display
- `project/data/starter_levels.json` — 10 level definitions
- `project/data/species_reference.json` — species specs, interactions, traits
- `project/data/click_a_coral_subjects.json` — Zooniverse image entries

## Field name reference
- `starting_nutrients` (was starting_fishfood)
- `reward_coins` (was reward_fishfood)
- `global_coins` (was rewards_total + carryover_fishfood)
- `current_level_available_nutrients` (was current_level_available_fishfood)
- Supabase column `rewards_total` = global_coins (backward compat)

## Architecture
- AppController is Godot autoload at `/root/AppController`
- State: `AppController.state → _sanitized_state() → JSON → level_progress_changed signal → level_system.gd`
- All new UI built programmatically in GDScript — no .tscn edits needed
- Tank scene: `res://scenes/hub/the_tank.tscn`
