# World Progression & Map

## World map structure

```
Position 0: The Tank (always unlocked, always accessible)
Position 1–10: Levels (linear unlock — complete N to unlock N+1)
```

The Tank sits at position 0 on the world map. Levels unlock sequentially.

## Level unlock

- Linear: completing level N unlocks level N+1
- Completed level node flips to "completed" visual state on world map
- Replaying a completed level: available anytime; gallery mode for identify phase (all prior images)

## Geographic theming

Levels track a real journey from USA south through the Caribbean to South America:

| Level | Site | Country/Region | Depth | Key feature |
|---|---|---|---|---|
| 0 (Tank) | The Tank | — | — | Personal reef; no location |
| 1 | Florida Keys NMS | USA | 5–15m | Beginner; Madracis + Blue Chromis |
| 2 | Mesoamerican Barrier Reef | Belize | 10–20m | Diverse gorgonians |
| 3 | Cayman Wall | Cayman Islands | 20–30m | Deeper species begin |
| 4 | Andros Reef | Bahamas | 15–25m | Urchin stressor introduced |
| 5 | Grace Bay | Turks & Caicos | 5–20m | Environment mismatch challenge |
| 6 | Bonaire NMP | Bonaire | 10–30m | Competing coral puzzle |
| 7 | Mushroom Forest | Curaçao | 15–40m | Salinity + temp puzzle |
| 8 | Los Roques Archipelago | Venezuela | 30–50m | Deep; Madrepora; tight turns |
| 9 | Fernando de Noronha | Brazil | 15–40m | Bleaching event level |
| 10 | Speyside Reef | Trinidad & Tobago | 10–30m | Max complexity |

World map pans NW→SE: Florida → Belize → Cayman → Bahamas → Turks → Bonaire → Curaçao → Venezuela → Brazil → T&T. Levels 8–10 push south, map may scroll.

World map data shape: `data/world_map_layout.json` — add `location` field per site (see reef-sites-geography.md for coordinates).

## The Tank

- Position 0; sandbox hub; always unlocked
- Idle coin generation: **1 coin/coral/hr + 0.3 coins/fish/hr**
- "Collect" button to gather idle coins
- Fish population management (no turn limit, no puzzle goal)

### v0.1 scope (confirmed)

The Tank in v0.1 is **threat-free and idle-only**:
- Place fish
- Grow coral
- Feed fish
- See what happens (species interactions play out passively)
- Collect passive coin rewards
- No stressors, no events, no fail states

**REMINDER (2026-03-31):** Add in-game stressors to The Tank in 2 sprints. These would occur passively in The Tank but would **NOT penalise players when they're not in The Tank** (offline-safe). See [backlog/future.md](../backlog/future.md).

Narrative + full sandbox expansion deferred to v0.2+ (trigger date 2026-04-06).

## Subject image caching

On world map load: for each unlocked level, prefetch subject image URL.
Store: `user://subject_cache/{subject_id}.jpg`
Show download indicator on locked levels not yet cached.
If image missing and offline: show placeholder reef silhouette in identify phase.

## Replay gallery

Replaying a completed level: player always gets a **new Zooniverse anomaly** (fresh subject from the level's subject pool). Identify phase always re-runs — no skipping.

All anomalies the player has classified for a level are shown on the **level node on the world map** — a growing collection of their past reef classifications, visible to them at any time.

## Technical

- `home_screen.gd` — level select, Tank button, coins display
- World map scene: `home.tscn`
- `AppController.tutorial_complete: bool` — persists to save file
