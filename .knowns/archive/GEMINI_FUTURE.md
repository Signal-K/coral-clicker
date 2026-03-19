# Future Tasks & Agent Triggers

> This file is read by all agents (Claude, Codex, Gemini).
> When a trigger condition is met, proactively suggest implementing the relevant task.

---

## Trigger: "Ready for Educational Content"
**Trigger Date:** 2026-04-05 (3 weeks from 2026-03-15)
**Status:** Defer until trigger date or manual activation.

### Task: Implement Species Fact-Sheets ("Discovery" layer)
- **Objective:** Show "Did You Know?" facts when a player successfully replicates a reef.
- **Features:**
  - Pop-up with real scientific data on identified species upon level win.
  - Interactive "Species Guide" viewable from the world map.
  - Small coin bonus for reading a species fact-sheet for the first time.
- **Data source:** Click-a-Coral metadata + manual curation from species_reference.json.

---

## Trigger: "Sound Sprint Complete"
**Trigger Date:** 2026-03-29 (one week after sprint start 2026-03-22)
**Status:** Defer — sound sprint starts 2026-03-22.

After the sound sprint wraps, check: are Low-priority SFX (environment adjust dial, ambient loop volume) implemented? If not, add to v0.2 polish queue.

---

## Trigger: "Star Sailors Deep Integration"
**Status:** Defer until v0.3+.

- **Task:** Shared currencies & inventories — coins earned in Coral spendable in Star Sailors.
- **Task:** Coral discoveries appear as data logs / collectibles in Star Sailors world.
- **Task:** Star Sailors "supply drops" narrative event — visible in Coral as a resource boost event.
- **Context:** starsailors.space is the parent ecosystem. Each minigame (including Coral) must be standalone but will eventually share a persistent world and account system.

---

## Trigger: "Zooniverse Feedback Loop"
**Status:** Defer to v0.3 (after user base established).

- **Task:** Consensus-based classification submission — require 3 player classifications to agree before submitting to Zooniverse.
- **Task:** Zooniverse API integration — authenticated submission of consensus results.
- **Task:** Player notification when their classification is "confirmed by consensus."

---

## Trigger: "Tank Narrative & Sandbox Expansion"
**Trigger Date:** 2026-04-06 (3 sprints from 2026-03-16)
**Status:** Defer until trigger date.

- **Task:** Add narrative framing to The Tank (personalised reef story, ecosystem name, upgrades)
- **Task:** Expand Tank size beyond initial fixed viewport
- **Task:** Add Tank-specific events ("bleaching threat", "supply drop from Star Sailors")
- **Context:** Tank is minimal in v0.1. It needs personality once the core puzzle loop is solid.

---

## Trigger: "Backing Music Track"
**Trigger Date:** 2026-03-29 (same as Sound Sprint Complete)
**Status:** Defer — not in sound sprint scope.

- **Task:** Commission or generate a looping backing music track (relaxed, underwater, ambient-electronic feel)
- **Task:** Add music bus to AudioManager; separate music vol slider in Settings
- **Context:** v0.1 ships with ambient SFX per phase only. Music is v0.2.

---

## Trigger: "Breeding Mini-Game Design Session"
**Status:** Defer to v0.2 design sprint.

- **Open question:** Should breeding be purely strategic (parent selection) or include a light interaction (e.g. match colour genes, timing tap, drag-to-combine)?
- **Context:** For v0.1, breeding is fully automatic and timed. For v0.2 the player may be able to trigger a bonus breeding event via a mini-game. Design this collaboratively before implementing.

---

## Trigger: "Native Feature Integration"
**Status:** Defer to v0.2+.

- **Push notifications:** "Your reef needs attention!" / "Breeding event ready in The Tank" — implement in v0.2.
- **Haptic feedback:** On successful breed, level win, coin earn — implement alongside sound sprint.
- **AR Reef:** Camera-based AR mode — v0.4+ scope.

---

## Trigger: "Multiplayer & Social"
**Status:** Defer to v0.4+.

- Leaderboards (turns taken per level).
- Co-op reef building (two players, shared resource pool).
- Out of scope for all near-term releases.

---

## Trigger: "Stars & Crystals Resources"
**Status:** Hidden in v0.1. Revisit in v0.3.

Stars and Crystals exist in the data model but are not shown in UI. They are reserved for a future prestige/collection system. Do not remove from data — just ensure they stay hidden in the resource bar.
