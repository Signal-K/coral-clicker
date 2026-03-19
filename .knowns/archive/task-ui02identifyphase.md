---
id: ui02identifyphase
title: "Identify Phase — the level gateway (redesign)"
status: todo
priority: critical
labels:
  - citizen-science
  - level-start
  - core-mechanic
createdAt: '2026-03-15T00:00:00Z'
updatedAt: '2026-03-15T00:00:00Z'
---

# Identify Phase — the level gateway

## ⚠️ This is the most important mechanic in the game

The identify phase is NOT a dialog. It is NOT a tutorial. It IS the mechanism by which a level is configured. Without completing identification, there is no level. The species the player identifies define what they must replicate.

## Flow

```
Player taps level on world map
    ↓
Full-screen reef image (from click_a_coral_subjects.json)
    ↓
"What species can you see in this reef?"
Player taps species chips from a predefined list (multi-select)
    ↓  confirm
Player's selection saved to Supabase (offline queue if no connection)
Level goal = correct/expected species composition for this image
    ↓
Level starts: player must replicate THAT composition
```

## Why the level uses "correct" composition, not player's

Player classifications are citizen science data — they may be wrong. The puzzle target comes from pre-curated level data (starter_levels.json), not the player's live input. Player's tags are stored for Zooniverse consensus later. The narrative is: "You identified this reef. Now rebuild it."

## Classification accuracy scoring (longer-term architecture)

Player accuracy cannot be scored immediately — we don't know if they're right until enough other players classify the same image. Architecture:

1. Each classification stored in `coral_classifications` table in Supabase
2. A **GitHub Action** runs on a schedule (e.g. nightly or weekly)
3. It queries all subjects with ≥ 3 classifications → computes consensus (most-selected species per subject)
4. It upserts consensus results into a `classification_consensus` table
5. Each player's historical classifications are compared against consensus → accuracy score per subject → stored in `player_accuracy` or `level_progress` table
6. In-game: the accuracy score surfaces at some point (v0.3+ — deferred; see GEMINI_FUTURE.md)

Schema additions (v0.3):
```sql
create table classification_consensus (
  subject_id text primary key,
  consensus_species text[],
  classification_count int,
  computed_at timestamptz
);
alter table level_progress add column if not exists accuracy_score float;
```

## UI requirements

- Full-screen image panel with **zoom/pan** (pinch to zoom; drag to pan)
- Species selection chips (with sprite thumbnails) in a scrollable grid below image
- Chips show ALL species in the game — not filtered by reef site
- "I'm not sure" chip — skips the **ENTIRE phase** (not individual species). Player still proceeds to level but no classification is logged
- Confirm button — disabled until ≥1 chip selected (or "I'm not sure" tapped)
- No skip of the entire phase except via "I'm not sure"
- After confirm: brief animated transition into the level (image zooms out to become the objective card)

## Data

- Images from `project/data/click_a_coral_subjects.json` — subject_id maps to level
- Species list comes from `species_reference.json` corals array
- Offline: queue classification in `AppController._pending_classifications`; sync on reconnect

## State machine

In `level_system.gd`, add `PHASE_IDENTIFY` state (currently exists but flow is wrong):
- Enter: show identify scene, pass subject image path
- Exit (on confirm): receive selected species array → log them → transition to `PHASE_PLAY`

## Scene

- `scenes/ui/IdentifyPhase.tscn` — full-screen overlay/page
- Species chip: `scenes/ui/SpeciesChip.tscn` — sprite + name, toggle state

## Technical notes

- The image shown should be the SAME image as the level's target composition
- Store `player_classification: Array[String]` in level state for Supabase upload
- Do not block level start if Supabase is unavailable — always save locally first
