---
id: sp02sfx
title: "Sound effects sprint"
status: todo
priority: medium
labels:
  - audio
  - polish
sprintStart: '2026-03-22'
createdAt: '2026-03-15T00:00:00Z'
updatedAt: '2026-03-15T00:00:00Z'
---

# Sound effects sprint

**Start date: Sunday 2026-03-22**

## Sound events needed

| Event | Description | Priority |
|---|---|---|
| Fish hatch | Light "blop" / bubble pop when egg hatches | High |
| Coral grow | Soft crystalline chime on turn growth | High |
| End Turn press | Gentle whoosh/underwater thud | High |
| Level complete | Rising warm chord + bubble cascade | High |
| Level fail | Low resonant "thunk" (not harsh) | High |
| Identify confirm | Soft notification chime | Medium |
| Fish card tap | Light underwater click | Medium |
| Coin earn | Small coin clink (keep relaxed) | Medium |
| Breeding event | Soft shimmer / ripple | Medium |
| Environment adjust | Soft dial-turn sound | Low |
| Ambient background | Gentle ocean ambience loop (quietable) | High |

## Audio design direction

- **Relaxed, not alarming.** No harsh sounds.
- Underwater / oceanic feel throughout.
- All SFX: short (< 1s), satisfying, earphone-friendly.
- **Backing music track is DEFERRED to v0.2.** Do not implement in this sprint.

## Ambient audio — phase switching

The ambient audio is NOT a single loop. It switches based on the current game phase:

| Phase | Ambient feel |
|---|---|
| Identify Phase | Quieter, expectant — gentle distant ocean, minimal bubble texture |
| Puzzle Phase | Active underwater ambience — mild current, fish movement texture |
| Level End Screen | Warm, resolved — calmer waves, slight brightness |

Each phase has its own ambient audio asset. `AudioManager.play_ambient(phase: String)` handles switching with a short crossfade (0.5s).

## Technical

- All audio as `.ogg` (Godot preferred format)
- `AudioManager` autoload singleton: `project/audio_manager.gd`
  - `play_sfx(name: String)` — plays one-shot from pool
  - `play_ambient(phase: String)` — crossfades to correct ambient loop for given phase
  - `stop_ambient()` — fades out current ambient
- Audio bus: SFX bus (vol adjustable) + Ambient bus (vol adjustable)
- **Sound/volume settings accessible ONLY from the main Settings screen** — no in-level sound controls

## Asset sources

Explore in priority order:
1. Generate with a tool (sfxr, jsfxr, Bfxr) for bleeps/pops
2. Freesound.org (CC0 licensed only)
3. Custom recordings (water, bubbles)

## Notes for this sprint

Focus only on High and Medium priority events for first pass. Low priority deferred to v0.2.
