# Future Backlog — Deferred Features

_Triggers and v0.2+ scope. Do not implement until trigger condition met._

## Confirmed reminders (2026-03-31 sprint)

These were scoped out of current sprint. Do not implement until the sprint that begins ~2026-03-31.

- **Custom species faces/colours** — when a player breeds a new species, allow mix-and-match face/colour from a defined list. See [tasks/task-future-v02species-creator.md](../tasks/task-future-v02species-creator.md)
- **Tank stressors** — add passive in-game stressors to The Tank that do NOT penalise offline players. See [tasks/task-future-v02tank-stressors.md](../tasks/task-future-v02tank-stressors.md)

---

## v0.2 — Polish & Hub (~2026-03-29 sprint)

- Backing music track (looping, relaxed underwater ambient-electronic)
- Tank narrative + sandbox expansion (trigger date: **2026-04-06**)
  - Add narrative framing to The Tank (personalised reef name, upgrades)
  - Tank-specific events: "bleaching threat", "supply drop from Star Sailors"
  - Expand Tank viewport beyond initial fixed size
- Push notifications: "Your reef needs attention!" / "Breeding event ready in The Tank"
- Star Sailors simple integration: save annotations to shared Supabase (v0.2 scope)
- Breeding mini-game design session (open question — before v0.2 build)
  - Parent selection only, OR light matching/gene mechanic?
  - For v0.1 breeding is fully automatic; v0.2 may add player-triggered bonus event

## v0.3 — Zooniverse & Education (~2026-04-05 trigger)

- **Species fact-sheets ("Discovery" layer)**
  - "Did You Know?" pop-up on level win showing real scientific data
  - Interactive "Species Guide" from world map
  - Small coin bonus for first-time fact-sheet read
  - Data source: Click-a-Coral metadata + curated from `species_reference.json`
- **Consensus-based classification**
  - Require 3 players to agree before Zooniverse submission
  - Zooniverse API: authenticated submission of consensus results
  - Player notification when classification confirmed by consensus
- Stars & Crystals: resurface in UI (prestige/collection system design TBD)

## v0.3+ — Star Sailors Deep Integration

- Shared currencies: coins earned in Coral spendable in Star Sailors
- Coral discoveries appear as data logs / collectibles in Star Sailors world
- "Supply drops" narrative event visible in Coral as resource boost
- Context: starsailors.space is the parent ecosystem; each minigame eventually shares persistent world + account

## v0.4+ — Deferred

- Leaderboards (turns taken per level)
- Co-op reef building (2 players, shared resource pool)
- AR Reef: camera-based AR mode
- Native features: push notifications (v0.2), haptic feedback (sound sprint)

## Sound sprint follow-up (check after 2026-03-29)

After sound sprint: verify Low-priority SFX are done (environment dial, ambient loop volume). If not, add to v0.2 polish queue.
