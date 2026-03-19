# UI Layout

## Platform constraints

- **Mobile-first portrait** — primary target
- Landscape + desktop supported
- All tap targets ≥ 48dp
- Sprites: **248×248px** (viewport), separate art pass for card strip (72px)

## Visual palette

| Role | Colour | Hex |
|---|---|---|
| Base (deep ocean) | Dark blue | `#1C3561` |
| Text / surfaces | Off-white | `#F0F8FF` |
| Accent (cyan) | Cyan | `#00E5FF` |
| Reward / coins | Amber | `#FFB300` |

Brighter sci-fi white + deep ocean blue aesthetic.

## Screen layout zones

### Reef viewport (centre)
- Shows fish, coral, eggs
- Overlay icons for Feed / Net actions appear HERE (not inside card strip)
- Water conditions HUD always visible (thermometer + salinity droplet, corner of viewport)
- Egg sprites spawn here; player taps to hatch, drags to zone

### Top flow bar (TopFlowBar.tscn)
- Turn flow / phase indicator

### Bottom resource bar (BottomResourceBar.tscn)
```
[🌿 Nutrients: 24 ████░░]  [🪙 Coins: 148]  [Turn: 3/6]
```
No Stars/Crystals visible in v0.1.

### Fish card strip (horizontal, bottom or side)
- One card per species
- Tap card to select → Feed/Net overlay icons appear on viewport
- Population badge on each card
- Extinct (pop = 0) → card goes grey
- Tapping a grey extinct card shows **"Extinct"** label (no revive; informational only)
- If extinct species was essential (player identified in source image) → **level ends immediately** (see level-structure.md)
- Exact card layout and badge styling: see task-ui03fishcards.md in archive

### Side navigator (SideNavigator.tscn)
- Navigation between puzzle / shop / identify / settings

## Directional sprites

Fish face based on movement direction. Use Godot **AnimationPlayer** — NOT GDScript mirroring.

## Net action

- Feed + Net are overlay icons on the reef viewport when a card is selected
- Net draws from the shared **trigger budget** (see [docs/triggers.md](../docs/triggers.md)): each net use consumes 1 trigger
- Cannot spam-net; when trigger budget is exhausted: Net button **greyed out** with counter "Net 0/2" (or "0 triggers left")
- Counter shows remaining triggers: "Net 2/2" → "Net 1/2" → "Net 0/2"

## Ambient audio per phase

- Identify phase: distinct ambient audio
- Puzzle phase: distinct ambient audio
- Level end: distinct ambient audio
- Backing music track: deferred to v0.2
- Sound settings: accessible from main Settings screen only (not in-level)

## All UI built programmatically

New UI components (identify dialog, breeding preview, level end overlay, shop) built in GDScript — no `.tscn` edits needed for new features.
