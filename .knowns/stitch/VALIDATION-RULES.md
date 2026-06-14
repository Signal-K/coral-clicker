# Stitch Screen Validation Rules

When any Stitch design is generated (via MCP or screenshot), run through every rule below before touching GDScript. Fail = don't implement. Fix first.

---

## 1. Terminology audit

Replace or remove any term that has no meaning in this game:

| Stitch term | Reality check | Correct term |
|---|---|---|
| Sector / Sector N | No sectors exist | Level name or reef site (e.g. "Florida Keys NMS") |
| Mission / Intel / Logs | No such screens | (remove the nav tab entirely) |
| Depth / Pressure / Salinity stats on home screen | Depth is a per-level geographic note, not a home screen stat | (omit from home) |
| Node Telemetry / Telemetry | No telemetry concept | (omit) |
| Hull / Protocol / Status: Aborted | Military/nautical jargon | Plain English — see FailScreen |
| Classification Aborted | Classification happens in the Identify phase and is already done | "Reef reconstruction failed" |
| Terminal Log | No terminal concept | "What happened" |
| Telemetry Salvaged | No telemetry | "Your data still counted" |
| Abort to Map / Return to Base | No "base" concept | "Home" |
| Restart Classification | Classification ≠ level | "Retry Level" |
| Initiate Next Dive | Generic sci-fi verb | "Next Level" |
| SOURCE: [X] INTEL | "Intel" is filler | "SOURCE: ZOONIVERSE" |
| Coins | ✅ Correct — keep as-is | Coins |
| Nutrients | ✅ Correct — keep as-is | Nutrients |
| Reef site names | ✅ Keep (Florida Keys NMS, Bonaire NMP, etc.) | — |

---

## 2. Layout / structure audit

Check for Stitch's habitual layout problems on this project:

| Check | Rule |
|---|---|
| **Sidebar** | Game is **mobile-first portrait**. No sidebars. If Stitch added a left or right panel, delete it entirely. |
| **Nav tabs** (Mission / Intel / Logs / Map / etc.) | Only implement nav tabs that map to real screens in the game. Current real nav: level select → level → results/fail. |
| **Desktop-only layout** | If a design only makes sense wide, adapt it to portrait-first. Stack horizontally-split panels vertically instead. |
| **Notification bell** | No notification system exists. Remove. |
| **Search bar / filter bar** | Not a game feature. Remove unless explicitly requested. |
| **Breadcrumb / back arrow in modals** | Modals dismiss via explicit button. Don't add breadcrumbs. |

---

## 3. Data field / stat audit

Only show stats that actually exist in the game data model:

| Valid stats | Invalid stats (Stitch makes these up) |
|---|---|
| Nutrients (level-local) | Depth shown on home screen |
| Coins (global) | Pressure |
| Turn counter (N/max) | Node count / node telemetry |
| Species population | XP / experience points |
| Level number (1–10) | Stars earned (hidden in v0.1) |
| Reef site name | Coordinates overlay |
| Level completion status | Hull integrity |

---

## 4. Component keep/discard guidance

Stitch is better at component details than full-screen composition.

**Keep from Stitch designs:**
- Individual card shapes, border radii, color tokens
- Icon placements and pill/chip styling
- Metric readout boxes (large value + small label)
- Button tactile styling (shadow offset, press state)
- Section header patterns (colored border dot + label)

**Discard from Stitch designs:**
- Sidebar panels
- Nav tab sets that don't match real screens
- Any static placeholder data (fake coordinates, fake stats)
- Full-screen layout structure — rebuild from scratch using these rules

---

## 5. Quick word-list check

Grep the generated HTML/TSCN for these strings before implementing. If found, flag before proceeding:

```
sector
mission (as nav tab)
intel
logs (as nav tab)
node telemetry
telemetry
depth (on home screen)
pressure
hull
abort to map
return to base
restart classification
classification aborted
```
