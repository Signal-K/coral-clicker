---
id: gp08stressor-tooltip
title: "Stressor tooltip — Level 4 first encounter"
status: done
priority: medium
labels:
  - gameplay
  - ui
  - onboarding
createdAt: '2026-03-17T00:00:00Z'
updatedAt: '2026-03-20T00:00:00Z'
---

# Stressor tooltip — Level 4 first encounter

## Trigger

First time a stressor (Longspine Sea Urchin) is encountered — Level 4 only, first play through. On replay, the tooltip is suppressed (player has seen it).

## Timing: mid-cycle

The tooltip appears **mid-cycle** — after the stressor spawns/is detected but **before it applies its damage for the first time**. This gives the player a chance to see and understand the threat before they're penalised.

After the player dismisses the tooltip, the turn cycle resumes and damage is applied normally.

## Content

The tooltip must include **both**:
1. **Warning** — "A Longspine Sea Urchin has appeared! It will damage your Madracis and Madrepora coral each turn."
2. **Counter hint** — "Creole Wrasse are natural predators of sea urchins. Add one to your reef to control the threat."

Keep it brief. Two-part structure: threat + solution. No need for lengthy explanation.

## Dismissal

- Single "Got it" / "OK" button
- No auto-dismiss on timer (player must acknowledge)
- Once dismissed: persisted to save file so tooltip never shows again for Level 4

## Technical

- `AppController.stressor_tooltip_shown: Dictionary` keyed by stressor ID (e.g. `"urchin"`)
- Tooltip hooked into `_advance_turn()` at the point stressor damage would be applied — pause cycle, show tooltip, wait for dismiss, then apply damage
- Built in GDScript panel (no `.tscn` edit required)

## Design reference

See [docs/level-structure.md](../docs/level-structure.md) — "Stressor introduction (Level 4)" section.
