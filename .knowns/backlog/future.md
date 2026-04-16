# Future Backlog — Deferred Features

_Deferred from v0.1 MVP. Do not implement until trigger condition met._

---

## v0.2 — Polish & Hub (~2026-05-01 trigger)

- **Custom species faces/colours** — when a player breeds a new species, allow mix-and-match face/colour from a defined list. See [archive/task-future-v02species-creator.md](../archive/task-future-v02species-creator.md)
- **Trait system (gp09)** — research real ecological traits for all root species; implement Mendelian inheritance + bonus chance; breeding preview dialog; new species naming. Deferred because it requires a research pass before any code and blocks nothing in MVP. Full spec: [archive/task-gp09traits.md](../archive/task-gp09traits.md)
- **Breeding mini-game** — v0.1 breeding is fully automatic; v0.2 may add player-triggered bonus event (parent selection / light gene-match mechanic). Design session required before build.
- **Backing music track** — looping relaxed underwater ambient-electronic
- **Tank stressors** — passive in-game stressors in The Tank that do NOT penalise offline players. See [archive/task-future-v02tank-stressors.md](../archive/task-future-v02tank-stressors.md)
- **Push notifications** — "Your reef needs attention!" / "Breeding event ready in The Tank"
- **Tank narrative expansion** — personalised reef name, upgrades, Tank-specific events ("bleaching threat", "supply drop from Star Sailors"), expanded viewport
- After sound sprint: verify low-priority SFX are done (environment dial, ambient loop volume). If not, add to v0.2 polish queue.

---

## v0.3 — Zooniverse & Education (~2026-06 trigger)

- **Species fact-sheets ("Discovery" layer)**
  - "Did You Know?" pop-up on level win with real scientific data
  - Interactive "Species Guide" accessible from world map
  - Small coin bonus for first-time fact-sheet read
  - Data source: Click-a-Coral metadata + curated from `species_reference.json`
- **Consensus-based classification**
  - Require 3 players to agree before Zooniverse submission
  - Zooniverse API: authenticated submission of consensus results
  - Player notification when classification confirmed by consensus
- **Classification accuracy score** — visible in player profile; historical identifications compared to expert/consensus. See identify-phase.md.
- **Stars & Crystals** — resurface in UI (prestige/collection system design TBD)
- **Star Sailors simple integration** — save annotations to shared Supabase

---

## v0.3+ — Star Sailors Deep Integration

- Shared currencies: coins earned in Coral spendable in Star Sailors
- Coral discoveries appear as data logs / collectibles in Star Sailors world
- "Supply drops" narrative event visible in Coral as resource boost
- Context: starsailors.space is the parent ecosystem; each minigame eventually shares persistent world + account

---

## v0.4+ — Deferred

- Leaderboards (turns taken per level)
- Co-op reef building (2 players, shared resource pool)
- AR Reef: camera-based AR mode
- World map v2 location-spine design (see docs/world-progression-v2.md for agreed direction)
