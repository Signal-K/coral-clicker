# Active Backlog — Current Sprint

_Last updated: 2026-04-23_

See also:

- [MVP audit 2026-04-11](/Users/scroobz/Navigation/Coral/.knowns/docs/mvp-audit-2026-04-11.md)

## What we're building

Player views a real Zooniverse reef photo and classifies what species they see (citizen science). That transitions into the puzzle: starting from an existing reef, the player feeds fish, places hatched eggs into zones, adjusts ocean temperature and salinity, and nets problem species — all to drive the ecological interactions that cause coral populations to grow, die, or shift composition. Every turn end resolves the fish↔coral↔environment interactions and shows the player how close they are to the target reef composition. Win = reef matches target within the turn limit.

Every screen and interaction in the active tasks below serves this loop.

---

## Priority sequence — work in this order

### 1. pwa01 — Product shell (web/PWA)
**Priority:** CRITICAL BLOCKER | **Labels:** pwa, web, ux

The browser entry point is currently a debug wrapper (`Coral Host Controls`) with direct bridge/level/Supabase controls exposed. It must become a player-facing product shell before any other polish makes sense.

- Replace `web/app/page.tsx` debug UI with a production shell
- Remove bridge log, direct level buttons, and Supabase read/write controls from player-visible surface
- Shell should present the game canvas cleanly with no developer affordances visible to players
- Ensure PWA manifest, offline support, and install prompt work end-to-end

**Source:** `web/app/page.tsx:55`

---

### 2. content-levels — Level content + real subject IDs
**Priority:** HIGH BLOCKER | **Labels:** content, data

Levels 2–3 and 5–10 have TBD targets. No level has real `subject_id` values wired. Nothing can be properly playtested without this.

- Assign real `subject_id` from `click_a_coral_subjects.json` to every level
- Complete target coral, starting fish, nutrients, and population cap for Levels 2–3 and 5–10 (see levels.md for partial data and level-structure.md for difficulty curve)
- Design "kill a coral" puzzle chains for Levels 6–10 (see level-structure.md §kill-a-coral)
- Wire stressor species into Level 4 (Longspine Sea Urchin), Level 6 (second stressor), Levels 9–10 (three stressors)
- Update `starter_levels.json` and `content/levels.md` together

**Design details:** [docs/level-structure.md](../docs/level-structure.md), [content/levels.md](../content/levels.md)

---

### 3. identify-mandatory — Enforce mandatory identify on non-tutorial levels
**Priority:** HIGH BLOCKER | **Labels:** ux, identify-phase

The identify scene still has a skip affordance outside tutorial flow. Identify is locked as mandatory on every non-tutorial level — remove the skip path.

- Remove or gate the non-tutorial skip path in `identify_phase.gd:27`
- "I'm not sure" remains valid (skips individual chip selection, not the whole phase)
- Tutorial (`is_tutorial: true`) retains its shortened 2-chip flow and no classification submission

**Source:** `project/scenes/ui/identify_phase.gd:27`

---

### 4. gp07 — Results panel redesign
**Priority:** HIGH | **Labels:** gameplay, ui

The current results panel treats all rows the same. It breaks down at 6–8 species and doesn't distinguish target species from stressor species.

- Per-species row: current population / target population (e.g. "Madracis sp. 4 / 8")
- Stressor species (e.g. Longspine Sea Urchin) shown in a distinct threat section — not the same row format as target species
- Turns remaining shown prominently
- Scrollable for large species counts (Levels 7–10 have 6–8 species)
- Blocks all input until "Continue" is tapped

**Source:** `project/scenes/ui/turn_results_panel.gd:21`

---

### 5. gp03 — Resource system + environment dials
**Priority:** HIGH | **Labels:** gameplay, economy, ui

- Hide Stars/Crystals from `BottomResourceBar.tscn` and `level_system.gd` (not in v0.1)
- Environment controls: 3-position dial (Cold/Moderate/Warm for temperature; Low/Medium/High for salinity)
- Each notch costs 5 coins AND 1 trigger — both must be available or adjustment is blocked
- If coins < 5: +/− button shakes/flashes red
- If triggers = 0: buttons greyed out
- Remove Nutrient Boost, Stressor Repellent, Coral Seed from shop (v0.1 scope only)
- Water conditions HUD always visible in reef viewport corner (thermometer icon + salinity droplet)

**Design details:** [docs/economy.md](../docs/economy.md), [docs/triggers.md](../docs/triggers.md)

---

### 6. gp06 — Trigger system
**Priority:** HIGH | **Labels:** gameplay, economy, ui

Per-turn action budget gates netting and environment changes — the strategic constraint that makes turns meaningful.

- `_triggers_remaining` resets to 2 at each turn start (plus any `_carryover_triggers`)
- Net a fish: costs 1 trigger
- Adjust temperature or salinity dial (per notch): costs 1 trigger
- Feeding fish does NOT cost triggers
- Trigger counter UI near Net button: "Net 2/2" → "Net 1/2" → "Net 0/2"
- When triggers = 0: Net button and dial buttons greyed out and non-interactive until next turn
- Research ecological feedback loops for salinity cascade effects (see triggers.md)
- Carryover triggers: unspent triggers can roll over as level completion reward; shown on Level End Screen

**Full spec:** [docs/triggers.md](../docs/triggers.md)

---

### 7. gp05 — Starvation mechanic
**Priority:** MEDIUM | **Labels:** gameplay, animation

When population cap is exceeded, oldest/least-fed fish die — breeding never stops.

- Death targeting: oldest fish that was fed latest (least-recently-fed among oldest); not random
- Animation sequence: grey colour fade → species-specific death animation → slow fade out
- Breeding continues over cap; eggs still hatch; starvation culls the excess

**Full spec:** [archive/task-gp05starvation.md](../archive/task-gp05starvation.md)

---

### 8. gp08 — Stressor tooltip (Level 4 first encounter)
**Priority:** MEDIUM | **Labels:** gameplay, ui, onboarding

First time a stressor appears (Level 4: Longspine Sea Urchin), a tooltip interrupts mid-cycle before damage is applied.

- Mid-cycle modal: explains the stressor, shows the counter strategy (net it OR introduce Creole Wrasse)
- One-time only — persisted to save so it never shows again
- Pauses turn resolution until dismissed
- Reappears after turn resolves so player sees the actual damage

**Full spec:** [archive/task-gp08stressor-tooltip.md](../archive/task-gp08stressor-tooltip.md)

---

### 9. gp10 — Fail screen
**Priority:** MEDIUM | **Labels:** gameplay, ui

- Specific fail reason text (e.g. "Turn limit reached", "Essential species extinct: Madracis sp.")
- XP notice: player is shown they earned XP for their reef classification regardless of failing the puzzle
- "Restart" button: returns to Identify Phase for this level (always a new Zooniverse image on replay)
- "Back" button: returns to world map

**Full spec:** [archive/task-gp10fail-screen.md](../archive/task-gp10fail-screen.md)

---

### 10. tutorial-level0 — Tutorial mission (Level 0)
**Priority:** MEDIUM | **Labels:** gameplay, onboarding

- `TutorialOverlay.tscn` with step text + highlight ring on each interactive element
- `tutorial_steps.json` in `res://data/`
- `is_tutorial: true` flag in `level_system.gd` disables fail state
- `AppController.tutorial_complete: bool` persists to save; tutorial never repeats
- Fixed composition: Madracis sp. ×4, Blue Chromis ×2, 40 nutrients, 10 soft turns
- Scripted walkthrough: Identify (2 chips, placeholder image) → Feed fish → End Turn → Results → Auto-breed egg → Win

**Full step spec:** `archive/task-tutorial-level0.md`

---

### 11. tank-mvp — The Tank (MVP scope)
**Priority:** MEDIUM | **Labels:** hub, ux, gameplay

The Tank is confirmed in MVP. Current state reads as a utilitarian management screen — needs to feel like a reward destination.

- Bonus fish and coral earned in levels are stored here and visible as living entities in the tank viewport
- Decorative interaction: player can tap fish/coral to get a brief info/reaction
- Passive production: The Tank generates a small coin trickle over time (rate TBD)
- Visual hierarchy: stored species shown prominently, not as a list

**Source:** `project/scenes/hub/the_tank.gd:44`

---

### 12. inf01 — Offline-first + Supabase sync
**Priority:** MEDIUM | **Labels:** infra, supabase, offline

- All 10 levels fully playable offline
- Classification queue: `user://pending_classifications.json` — drain on reconnect (silent; no error shown to player)
- Coins held until Supabase sync; "Reward pending sync" notice on Level End Screen if offline
- Subject image caching: `user://subject_cache/{subject_id}.jpg`; placeholder reef silhouette if offline and uncached
- Supabase schema: `coral_classifications` table; add `turns_used`, `coins_earned`, `classification_id` to `level_progress`

---

### 13. sp02 — Sound effects
**Priority:** MEDIUM | **Labels:** audio

- Ambient audio: identify phase, puzzle phase, level end (3 distinct tracks)
- SFX: egg hatch, fish feed, turn end, coin earn, level win, level fail
- Low-priority SFX: environment dial adjust, ambient loop volume fade
- Haptic feedback: breed success, level win, coin earn
- Sound settings: main Settings screen only (not accessible in-level)

---

### 14. qa-tour — QA tour pass
**Priority:** LOW (do last, before release) | **Labels:** qa, testing

Run the containerized tour before calling this MVP. Verify the full loop: world map → identify → puzzle (3 turns minimum) → win/fail → result screen → world map. Confirm offline path, pending reward notice, and mandatory identify enforcement.

---

## Done

| Task | Completed |
|---|---|
| ux02 — Identify Phase full-screen scene | Done |
| gp06 (partial) — Identity choice scene + effects | Done (see commit 401aff0e) |
