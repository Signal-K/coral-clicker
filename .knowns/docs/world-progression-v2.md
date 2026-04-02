# World Progression — v2 Plan

_Agreed direction: 2026-04-02_

Replaces the flat 10-level linear unlock with a **location-based structure** — each location is a distinct reef site with its own visual identity, species set, and environmental baseline. Daily unlocks drive return visits.

---

## Structure

### Locations (not individual levels)

Each **location** is a reef site. It has:
- 3–5 puzzle levels (short, not a long arc)
- Unique **water tint** (visibility/depth affects colour: Caribbean shallow = bright turquoise; deep wall = dark indigo; bleached reef = pale grey-white)
- **Environmental baseline** — some locations run warm by default, some are hypersaline, some light-deprived. This forces the player to work within the location's natural constraints, not an arbitrary number
- **Species set** restricted to what actually lives there — you don't see Atlantic gorgonians in an Indo-Pacific level
- A **field guide page** that fills in as you encounter species there

### Location unlock methods

| Method | Description |
|---|---|
| **Progression unlock** | Complete all levels in location N → unlock location N+1 (linear spine) |
| **Daily rotation** | One new event location or bonus location appears each day (refreshes midnight UTC) |
| **Event unlock** | Seasonal events (bleaching, spawning season, storm) unlock a temporary location for 48–72h |

The daily rotation is the retention hook. Players who have completed the spine still have a reason to open the app every day.

---

## Tutorial restructure — keep it short

Current plan: Level 0 is a scripted 10-turn tutorial with guided overlays.

**New approach**: Keep Level 0 but cut it to a 3-step guided intro:
1. **Identify** — show the image, tap one species, that's it. One tap, instant success.
2. **Breed** — one egg appears immediately (interval set to 2s). Tap to hatch, drag to zone.
3. **End Turn** — press End Turn. Win screen. Done.

No fail state. No nutrient bar complexity shown. No stressors. No environment dials. Everything else is introduced via in-context tooltips when the player first encounters it (stressor tooltip pattern already exists — extend this to environment dials, breeding, nets).

Total tutorial time: ~90 seconds.

The first real location (Location 1: Florida Keys shallow) teaches nutrients and environment implicitly across its 3 levels, rather than a scripted tutorial doing it explicitly.

---

## Location spine (v0.1–v0.2 scope)

| # | Location | Depth | Water tint | Species focus | Mechanic introduced |
|---|---|---|---|---|---|
| 0 | The Nursery | Shallow | Bright turquoise | Madracis sp. only | Tutorial — identify, breed, end turn |
| 1 | Florida Keys | Shallow (5–15m) | Clear blue | Madracis sp., Blue Chromis, Creole Wrasse | Nutrients, basic environment |
| 2 | Belize Barrier Reef | Mid (15–30m) | Deep teal | Add gorgonians | Temperature dial matters |
| 3 | Cayman Islands | Mid-deep (30–50m) | Blue-grey | Cold-preferring species appear | Cold specialist mechanic |
| 4 | The Bahamas Ledge | Mid (20–40m) | Blue | Stressor introduced | First urchin — Creole Wrasse counter |
| 5 | Bonaire Wall | Deep (50–80m) | Dark indigo | Two competing corals | Kill-a-coral chain |
| 6 | Curaçao Deep | Deep (60–100m) | Near-black | Full stressor + environment pressure | Multi-step deduction |

---

## Daily events (rotation pool)

Events unlock for 48h. Player can attempt them any time during the window. Completing an event level earns bonus coins and a species field guide entry.

| Event | Visual change | Mechanic change |
|---|---|---|
| **Spawning Season** | Water fills with particle effects (eggs/larvae) | Breeding interval halved — eggs appear constantly; nutrient management is harder |
| **Bleaching Event** | Water tint washes pale; coral sprites desaturate | Temperature forced +1 warm each turn unless countered with coins; stony corals take extra damage |
| **Storm Surge** | Dark water, particle storm, reduced visibility | One random fish population reduced at start of each turn; salinity fluctuates |
| **Cold Upwelling** | Blue-green tint, colder colour grade | Deep-water species thrive; tropical fish take cold damage; different viable strategy |
| **Algae Bloom** | Green tint overlay | All corals take -1/turn unless herbivore fish kept above threshold |

One event in the daily rotation. Events rotate on a weekly cadence so regulars see all of them.

---

## Species field guide (collection layer)

A global field guide accessible from the world map. Each species has:
- Real photograph (from Click-a-Coral subject images)
- Common name + scientific name
- Depth range, temperature preference, role in reef
- Status: **Unseen** / **Spotted** (encountered in identify phase) / **Studied** (completed a level where they were present)

Collecting all entries for a location unlocks a **location badge** on the world map node.

This gives players who've cleared all puzzle levels a secondary goal: get every species to "Studied" status.

---

## What this replaces

Old design element → new approach:

| Old | New |
|---|---|
| 10 flat linear levels | Location spine + daily events |
| Long scripted Level 0 tutorial | 3-step 90s intro then implicit teaching |
| Post-level classification quiz (removed) | Identify phase at level start is the only science moment; result shown on level end screen |
| Stars/Crystals (hidden, TBD) | Defer to v0.3 — could become location badges or field guide completion rewards |
| World map nodes flip to "completed" | World map nodes become living reef nodes (animated fish visible in completed nodes) |

---

## Data model changes needed

`starter_levels.json` gains a `location_id` field per level. Locations defined in a new `locations.json`:

```json
{
  "locations": [
    {
      "id": "florida_keys",
      "name": "Florida Keys",
      "water_tint": "#1A7FBF",
      "depth_range": "5–15m",
      "env_baseline": { "temperature": 0, "salinity": 0 },
      "unlock_type": "progression",
      "levels": [1, 2, 3]
    }
  ]
}
```

Daily event entries in a `daily_events.json` (or generated server-side from Supabase edge function on a cron).
