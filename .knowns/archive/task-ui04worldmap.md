---
id: ui04worldmap
title: "World map home screen"
status: todo
priority: high
labels:
  - ui
  - navigation
  - home
createdAt: '2026-03-15T00:00:00Z'
updatedAt: '2026-03-15T00:00:00Z'
---

# World map home screen

Replaces the current grid-based level select screen.

## Concept

A stylised underwater map showing 10 reef sites. Each site is a node the player can tap. Sites are **geographically themed** based on where the featured species actually live — see `reef-sites-geography.md` for location research and species distribution.

Completed levels show a Zooniverse thumbnail on the map node. If replayed, a **gallery view** opens showing ALL images the player has seen for that level (not just first or most recent).

## Layout

```
┌─────────────────────────────────────┐
│  CORAL CLICKER           Coins: 248 │
│  ─────────────────────────────────  │
│                                     │
│    🪸 Site 1    🪸 Site 2            │
│         🔒 Site 3  🔒 Site 4         │
│    🔒 Site 5                        │
│              [THE TANK] ←── hub     │
│                                     │
│  [Profile]              [Settings]  │
└─────────────────────────────────────┘
```

- Map is scrollable/zoomable (pan gesture) for later when there are more than 10 levels
- **The Tank is at position 0** — always unlocked, always accessible; it is not a button overlay, it is a map node
- Level unlock is strictly **linear** — complete level N to unlock N+1

## Level node states

| State | Visual |
|---|---|
| Locked | Grey icon, lock overlay |
| Available | Animated sprite, pulsing ring |
| Completed | Thumbnail of most recent Zooniverse image seen |
| Replaying | Tap completed node → opens gallery view of all images seen for that level |
| The Tank (pos 0) | Always animated/unlocked; distinct visual from level nodes |

## Transitions

- Tap level node → brief zoom-in animation → Identify Phase screen
- Tap The Tank → zoom to tank scene
- Level completion → animate back to map; node flips to "completed" state

## Technical

- Scene: `scenes/hub/WorldMap.tscn` — replaces `home.tscn`
- Level state stored in `AppController.level_progress` (already exists)
- Map background: hand-drawn ocean floor SVG or gradient + coral particle effects
- Level nodes positioned in `data/world_map_layout.json` (x/y coordinates on the map)

## Data shape for world_map_layout.json

```json
[
  { "level": 1, "x": 120, "y": 340, "name": "Nursery Reef" },
  { "level": 2, "x": 310, "y": 280, "name": "Coral Ridge" },
  ...
]
```
