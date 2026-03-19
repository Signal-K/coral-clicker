# Identify Phase

## What it is

The identify phase IS the level configuration — not a tutorial, not optional. Player views a real Zooniverse reef photo and tags species. This is citizen science embedded in gameplay.

**The level goal is pre-curated (from starter_levels.json) — NOT derived from the player's guess.** Player tags are stored for future consensus accuracy scoring.

## Flow

1. Full-screen Zooniverse reef image — zoom/pan enabled
2. ALL species chips shown (not filtered by reef site; player sees everything)
3. Player taps chips to select species (multi-select; min 1)
4. **"I'm not sure"** → skips the WHOLE identify phase (not individual chips)
5. Confirm → classifications queued → transition to puzzle phase
6. Correct identification = bonus coins at level completion

## Citizen science data pipeline

- Classifications saved to Supabase table `coral_classifications`
- If offline: appended to `pending_classifications.json` in `user://`, synced on reconnect
- No error shown to player if upload fails; queue drains silently
- v0.3: consensus-based submission (3 players agree before Zooniverse submission) — see [backlog/future.md](../backlog/future.md)

## Offline behaviour

- Subject images downloaded on first play per level, cached in `user://subject_cache/{subject_id}.jpg`
- If image not cached and offline: show placeholder reef silhouette
- See [docs/world-progression.md](world-progression.md) for image prefetch on world map load

## Replaying a level

On replay: player always goes through a **new Zooniverse anomaly** (a fresh subject image from the level's subject pool — not a repeat). This is confirmed; identify phase always re-runs on replay.

All anomalies the player has classified for a level **show up on the level selector / world map node** for that level — a growing gallery of their past classifications. This is visible on the map even before replaying.

## Tutorial (Level 0)

Level 0 does NOT use a Zooniverse image. Uses a placeholder / hand-drawn image. Only 2 species chips shown (guided). No real classification submitted.

## Classification accuracy (v0.3)

Player's historical identifications compared to expert/consensus classifications. Accuracy score visible in player profile. See GEMINI_FUTURE triggers in [backlog/future.md](../backlog/future.md).

## Technical

- Scene: `IdentifyPhase.tscn` (reused for tutorial with `is_tutorial: true` flag)
- `_on_identify_confirmed()` in `level_system.gd` → append to queue + attempt immediate upload
- Subject ID from `starter_levels.json` → look up in `click_a_coral_subjects.json`
