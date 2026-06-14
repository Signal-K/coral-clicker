# Stitch → GDScript Design Mapping

## Design System Tokens

### Colors (Stitch → GDScript Color())
| Token | Hex | GDScript |
|---|---|---|
| primary (cyan) | #52f2f5 | Color(0.322, 0.949, 0.961, 1) |
| secondary (coral/orange) | #fe7e4f | Color(0.996, 0.494, 0.310, 1) |
| tertiary (yellow) | #ffe792 | Color(1.0, 0.906, 0.573, 1) |
| error | #ffb4ab | Color(1.0, 0.706, 0.671, 1) |
| background | #001016 | Color(0.0, 0.063, 0.086, 1) |
| surface | #0e1415 | Color(0.055, 0.078, 0.082, 1) |
| surface-container-low | #00161d | Color(0.0, 0.086, 0.114, 1) |
| surface-container | #021d25 | Color(0.008, 0.114, 0.145, 1) |
| surface-container-high | #05232c | Color(0.02, 0.137, 0.173, 1) |
| surface-container-highest | #092933 | Color(0.035, 0.161, 0.2, 1) |
| on-primary (text on cyan) | #003739 | Color(0.0, 0.216, 0.224, 1) |
| on-surface (body text) | #dde4e6 | Color(0.867, 0.894, 0.902, 1) |
| outline | #40696d | Color(0.251, 0.412, 0.427, 1) |
| outline-variant | #1f4c50 | Color(0.122, 0.298, 0.314, 1) |

### Typography
| Role | Font | Size (pt) | Weight | Godot equivalent |
|---|---|---|---|---|
| Display/headline | Plus Jakarta Sans | 28–36 | 800–900 | custom font, bold |
| Title | Plus Jakarta Sans | 18–22 | 700 | custom font, bold |
| Label/data | Space Grotesk | 11–14 | 500–700 | custom font, medium |
| Body | Plus Jakarta Sans | 13–15 | 400 | custom font, regular |

Current code uses 12–26pt system font. Font imports needed.

### Spacing
| Token | px | Godot |
|---|---|---|
| unit | 4 | 4 |
| stack-gap | 12 | separation=12 |
| panel-padding | 16 | add_theme_constant_override("margin_*", 16) |
| gutter | 24 | add_theme_constant_override("margin_*", 24) |
| page-margin | 32 | outer container margin |

---

## Screen-by-Screen Mapping

### 1. World Map (home_screen.gd)

**Current:** Level buttons (58×58 StyleBoxFlat circles), Line2D routes, sidebar panel.

**Stitch target:** Tactical Console — radar sweep background, dial-based mission nodes (circular with concentric rings + level number + notification dot), active level shows large dial (28×28) with popover. Fixed header bar with cyan border, resource readouts. Route as animated dotted path.

**GDScript changes needed:**
- `_make_bubble_style()` → replace with dial node (custom draw or sub-scene): outer ring `outline` color, inner gradient `surface-container-high → surface-container`, center label in cyan
- `_make_coral_style()` → same dial for landmark markers
- Add radar sweep as `CanvasItem._draw()` conic gradient on background layer
- `_build_route_layer()` → keep Line2D but add dotted texture + animation
- Add top header bar: HBoxContainer with cyan 2px bottom border, title + coin/turn readouts as pill-shaped containers

---

### 2. System Shop (level_system.gd `_build_shop_overlay()`)

**Current:** 300px right-aligned panel, plain VBoxContainer rows with name + button + description.

**Stitch target:** Modal overlay with sandwich layout (header + scroll + footer). Egg items as circular icon containers in a grid (3–4 cols), with cost badge overlay, hover scale effect.

**GDScript changes needed:**
- Replace VBoxContainer item rows with GridContainer (3 cols on desktop, 2 on mobile)
- Each item: circular StyleBoxFlat container (pill 999px radius), icon centered, cost badge as small PanelContainer overlaid top-right
- Header: title + close button with tactile styling
- Footer: confirm/cancel buttons full-width

---

### 3. Identify Phase (identify_phase.gd)

**Current:** CanvasLayer with image, 2-column grid of IdentifyChoiceCard scenes, helper label.

**Stitch target:** Tactical Console with HUD reticle overlay on image. Species chips are pill-shaped with radio icon (Material Symbols checked/unchecked), arranged in 2-col grid. Bottom action bar with "Confirm" tactile button.

**GDScript changes needed:**
- Add SVG-style reticle overlay on reference image: concentric rings + corner brackets (drawn via `_draw()` or SubViewport)
- Choice cards → replace with pill chips: StyleBoxFlat corner_radius=9999, primary color border when selected, surface-container-high bg unselected
- Add breadcrumb/mission status pill in header: monospace "MISSION // IDENTIFY PHASE"

---

### 4. Turn Results (turn_results_panel.gd)

**Current:** CanvasLayer, fade-in panel, ProgressBar, staggered TurnResultRow instances.

**Stitch target:** Tactical Briefing — full-screen dark overlay, segmented 10-block progress bar (flex of styled panels, not ProgressBar), data readout boxes (monospace large value + small label), staggered row entries.

**GDScript changes needed:**
- Replace `ProgressBar` with HBoxContainer of 10 `PanelContainer` segments, filled = primary color + glow shadow, empty = surface-container-high
- Row entries: HBoxContainer with icon pill + species name + delta value in monospace
- Background: scanlines overlay (TextureRect with repeating gradient texture)

---

### 5. Mission Failure (level_system.gd `_build_level_fail_overlay()`)

**Current:** 460px centered panel, dark purple bg, title + description + restart/home buttons.

**Stitch target:** Tactical Briefing — full-screen overlay with scanlines CRT effect. Large "MISSION FAILED" headline with text-shadow glow in error red. Diagnostic panel with cause readout. Two tactile buttons.

**GDScript changes needed:**
- Expand to near-full-screen (max 640px wide, taller)
- Background: Color(0.0, 0.063, 0.086, 0.95) + scanlines TextureRect
- Title: error color (#ffb4ab), uppercase, large (30pt+)
- Diagnostic box: surface-container-high panel, monospace label + cause text
- Buttons: tactile 3D style (StyleBoxFlat with offset shadow + normal/pressed states)

---

### 6. Mission Success (level_system.gd `_build_level_end_overlay()`)

**Current:** 480px centered panel, dark blue bg, title + description + coins + next/home buttons.

**Stitch target:** Tactical Briefing — bento grid layout. Large success title in primary cyan with glow. Metrics bento grid (nutrients saved, species alive, turns taken) as data readout boxes. Holographic grid overlay on background. Tactile action buttons.

**GDScript changes needed:**
- Same full-screen treatment as failure
- Bento grid: GridContainer 2–3 cols, each metric cell = surface-container panel with large monospace value + small label
- Add holographic grid TextureRect overlay (blend: multiply)
- Coins display as primary-color pill

---

### 7. Puzzle Phase — Fish Cards (level_system.gd)

**Current:** fish_card_strip ScrollContainer, fish_card.gd PanelContainer cards with role hint chips.

**Stitch target:** Horizontal snap-scroll strip, cards with top color bar (role color), population dial (small circle with number), species name, role chip pills.

**GDScript changes needed (fish_card.gd):**
- Add top color bar: ColorRect 4px height at top of card, color = role tone
- Population count: small circular StyleBoxFlat (28×28, radius 999) in top-right corner
- Card bg: surface-container-high, rounded 16px corners

---

### 8. Puzzle Phase — Environment Controls + HUD

**Current:** Water HUD labels + dial buttons bound in `_bind_environment_ui()`.

**Stitch target:** Dial indicators (concentric rings, center readout value, colored indicator dot), resource bars with cyan fill + glow, turn/reef status as pill readouts in top bar.

**GDScript changes needed:**
- Environment dials: custom Control drawing concentric circles + indicator
- Resource bars: ColorRect inside HBoxContainer (fixed total width), primary color fill, glow via stylebox shadow
- Top status bar: fixed HBoxContainer with pills per resource

---

### 9. Immersive Mode (new screen)

Not yet implemented. Stitch shows a full-screen reef photo with minimal HUD overlay:
- Reticle (crosshair + concentric circles + corner brackets)
- Small HUD panels in corners (circular progress meters, data readouts)
- Bottom action strip

This is likely a future ticket.

---

## Implementation Priority

1. **Design token constants file** (`project/ui_theme.gd`) — color dict, spacing constants, shared StyleBoxFlat factories. Blocks everything else.
2. **Tactile button style** — shared across all screens, currently missing entirely.
3. **Mission Failure / Success overlays** — highest visibility, easiest to upgrade (self-contained).
4. **Fish cards** — visible every turn, meaningful improvement.
5. **Identify phase** — reticle + chip styling.
6. **Turn results panel** — segmented bar.
7. **Shop overlay** — grid layout.
8. **Home screen** — dial nodes + radar (most complex).
9. **Immersive mode** — new feature, separate ticket.

---

## Shared Components to Build

### `TactileButton` (StyleBoxFlat factory)
```gdscript
# Normal state: gradient top lighter → bottom darker, outer shadow 3px
# Pressed state: inset shadow, translate_y +2px
# Uses primary color for primary actions, surface-container-high for secondary
```

### `GlowPill` (inline label container)
```gdscript
# StyleBoxFlat corner_radius=9999, bg=surface-container-high
# border=outline-variant 1px, optional glow shadow in primary color
```

### `SegmentBar` (replaces ProgressBar)
```gdscript
# HBoxContainer of N PanelContainers
# filled: bg=primary, shadow=glow-cyan; empty: bg=surface-container-high
```

### `DataReadout` (monospace value box)
```gdscript
# VBoxContainer: large label (Space Grotesk 20pt) + small label (11pt uppercase)
# bg panel: surface-container, border: outline-variant
```
