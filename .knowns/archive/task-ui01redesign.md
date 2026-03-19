---
id: ui01redesign
title: "Ground-up UI redesign (mobile-first)"
status: todo
priority: critical
labels:
  - ui
  - ux
  - layout
  - mobile
createdAt: '2026-03-15T00:00:00Z'
updatedAt: '2026-03-15T00:00:00Z'
---

# Ground-up UI redesign (mobile-first)

## Goals

Replace the current cluttered landscape-biased layout with a clean, mobile-first design that works in portrait, landscape, and desktop at 1280×720+.

## Layout — Mobile Portrait (primary)

```
┌─────────────────────────────────┐
│  [Objective card — front/centre]│  ← replicate: Madracis + Thesea
│  Turns: 4 remaining             │
├────────────────────────────────-┤
│                                 │
│        REEF VIEWPORT            │  ← animated corals + fish
│     (takes most of screen)      │
│                                 │
├─────────────────────────────────┤
│  Turn flow: ① Adjust ② End Turn │  ← persistent step strip
├─────────────────────────────────┤
│  [Fish Cards — horizontal scroll]│
├─────────────────────────────────┤
│  Nutrients ███░░  Coins: 48     │  ← bottom resource bar
└─────────────────────────────────┘
```

## Palette

- Base: deep ocean blue (keep existing `#1C3561` family)
- Accents: bright white `#F0F8FF`, cyan `#00E5FF`, warm amber `#FFB300`
- Panels: `rgba(255,255,255,0.06)` glass effect on dark
- Remove: heavy border strokes; replace with subtle glow/shadow

## Design rules

- All interactive tap targets ≥ 48dp
- No horizontal scrolling of core UI (fish cards may scroll)
- Single column on portrait; two-column (reef | side) on landscape ≥ 600dp
- Nothing hidden behind undiscoverable gestures — all key actions always visible
- Remove: SideNavigator panel entirely; its content redistributed (see below)

## Redistributing SideNavigator content

| Old location | New location |
|---|---|
| Level navigation (prev/next) | World map screen only |
| Fish action rows | Fish card strip (bottom of game screen) |
| Status/Objective label | Objective card (top of game screen) |
| Turn/Reset/Sync buttons | Turn button in turn-flow strip; Reset in pause menu |
| Population counts | Fish card badges |

## Scenes to create/replace

- `scenes/layout/GameScreen.tscn` — new main game layout (replaces main.tscn assembly)
- `scenes/layout/ObjectiveCard.tscn` — front-and-centre level goal display
- `scenes/layout/FishCardStrip.tscn` — horizontal scrollable fish card row
- `scenes/layout/TurnFlowStrip.tscn` — persistent ①②③④ step indicator + End Turn button
- `scenes/layout/BottomResourceBar.tscn` — updated (nutrients + coins only)
- `scenes/layout/ReefViewport.tscn` — keep; adjust sizes for 248px sprites

## Scenes to retire

- `scenes/layout/SideNavigator.tscn` — delete after migration
- `scenes/layout/TopFlowBar.tscn` — delete after migration (replaced by ObjectiveCard + TurnFlowStrip)
