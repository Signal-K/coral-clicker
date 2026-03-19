# Active Backlog — Current Sprint

_Last updated: 2026-03-17_

## Design questions — RESOLVED 2026-03-17

All 10 open design questions answered on 2026-03-17. Docs updated; task files created (gp05–gp11). See task files for build specs.

---

## TODO Tasks

### gp03 — Resource system simplification
**Priority:** Medium | **Labels:** gameplay, economy, ui

- Hide Stars/Crystals from `BottomResourceBar.tscn` and `level_system.gd`
- Replace `+/-` environment buttons with 3-position dial (Low/Medium/High; Cold/Moderate/Warm)
- Wire environment dial to cost 5 coins per notch
- Show water conditions HUD on reef viewport at all times
- Remove Nutrient Boost, Stressor Repellent, Coral Seed from shop (v0.1 scope)

**Design details:** [docs/economy.md](../docs/economy.md), [docs/triggers.md](../docs/triggers.md)

---

### gp04 — 10-level content design
**Priority:** High | **Labels:** content, gameplay

- Design target coral, species, nutrients, and starting_fish for Levels 2, 3, 5–10
- Assign real `subject_id` values from `click_a_coral_subjects.json` to each level
- Update `starter_levels.json` with complete level entries
- Design stressor introduction timeline (Level 4: first urchin; Level 6: second type)
- Design "kill a coral" puzzle chains for Levels 6–10

**Design details:** [docs/level-structure.md](../docs/level-structure.md), [content/levels.md](../content/levels.md)

---

### tutorial-level0 — Tutorial mission
**Priority:** High | **Labels:** gameplay, onboarding

- Implement `TutorialOverlay.tscn` with step text + highlight ring
- Add `tutorial_steps.json` in `res://data/`
- Add `is_tutorial: true` flag handling in `level_system.gd`
- Disable fail state for Level 0
- `AppController.tutorial_complete: bool` persists to save
- Scripted fixed composition: Madracis sp. ×4, Blue Chromis ×2, 40 nutrients, 10 soft turns

**Full step spec:** `archive/task-tutorial-level0.md`

---

### sp02 — Sound effects sprint
**Priority:** High | **Start date:** 2026-03-22

- Ambient audio for identify phase, puzzle phase, level end (3 distinct tracks)
- SFX: egg hatch, fish feed, turn end, coin earn, level win, level fail
- Low-priority SFX: environment dial adjust, ambient loop volume fade
- Haptic feedback: breed success, level win, coin earn (alongside sound)
- Sound settings: main Settings screen only (not in-level)

---

### inf01 — Offline-first + Supabase sync
**Priority:** Medium | **Labels:** infra, supabase, offline

- All 10 levels fully playable offline
- Classification queue: `user://pending_classifications.json` — drain on reconnect
- Coins held until Supabase sync; "Reward pending sync" notice on Level End if offline
- Subject image caching: `user://subject_cache/{subject_id}.jpg`
- Supabase schema additions: `coral_classifications` table; add `turns_used`, `coins_earned`, `classification_id` to `level_progress`

**Design details:** see archive `task-inf01offline.md`

---

### gp05 — Starvation mechanic
**Priority:** Medium | **Labels:** gameplay, animation, fish

- Implement death targeting: oldest fish + least recently fed
- Implement grey fade → death animation → slow fade out sequence

**Full spec:** [tasks/task-gp05starvation.md](../tasks/task-gp05starvation.md)

---

### gp06 — Trigger system
**Priority:** High | **Labels:** gameplay, economy, ui

- Implement per-turn trigger budget (2 triggers/turn)
- Net + environment dial both draw from shared trigger pool
- Trigger counter UI, greyed-out state when exhausted
- Research ecological feedback loops for salinity changes
- Carryover triggers as level rewards

**Full spec:** [tasks/task-gp06triggers.md](../tasks/task-gp06triggers.md) | [docs/triggers.md](../docs/triggers.md)

---

### gp07 — Results panel
**Priority:** High | **Labels:** gameplay, ui

- Per-species current population vs target
- Turns remaining shown
- Scrollable for large species counts

**Full spec:** [tasks/task-gp07results-panel.md](../tasks/task-gp07results-panel.md)

---

### gp08 — Stressor tooltip (Level 4)
**Priority:** Medium | **Labels:** gameplay, ui, onboarding

- Mid-cycle tooltip: warning + counter hint
- One-time only (persisted to save)
- Pauses turn cycle until dismissed

**Full spec:** [tasks/task-gp08stressor-tooltip.md](../tasks/task-gp08stressor-tooltip.md)

---

### gp09 — Trait system
**Priority:** Medium | **Labels:** gameplay, breeding, content, research

- Phase 1: Research real ecological traits for all root species
- Phase 2: Implement inheritance mechanics (Mendelian + bonus chance)
- Phase 3: Breeding preview dialog
- New species naming (face/colour customisation deferred to 2026-03-31)

**Full spec:** [tasks/task-gp09traits.md](../tasks/task-gp09traits.md)

---

### gp10 — Fail screen
**Priority:** Medium | **Labels:** gameplay, ui

- Show specific fail reason
- Restart / Back buttons
- XP from classification always shown (regardless of fail)

**Full spec:** [tasks/task-gp10fail-screen.md](../tasks/task-gp10fail-screen.md)

---

### gp11 — Extinct card + essential species level end
**Priority:** Medium | **Labels:** gameplay, ui

- Tap grey card → "Extinct" label
- Essential species extinct → immediate level end with fail reason

**Full spec:** [tasks/task-gp11extinct-card.md](../tasks/task-gp11extinct-card.md)
