---
id: ux02-identify-phase-scene
title: "Convert Identify Phase from popup to full-screen scene"
status: done
priority: urgent
labels:
  - ui
  - ux
  - identify-phase
createdAt: '2026-03-23T00:00:00Z'
updatedAt: '2026-03-23T22:50:00Z'
---

# Convert Identify Phase from popup to full-screen scene

## Problem

Currently, the Identify Phase (where the user identifies species in an image) is implemented as an `AcceptDialog` popup overlaying the game screen. This feels cluttered and doesn't give enough focus to the high-quality reef imagery being analyzed. The popup approach is also inconsistent with the "full-screen citizen science" vision.

## Required outcome

- Replace the `AcceptDialog` in `level_system.gd` with a dedicated, full-screen UI.
- The Identify Phase should feel like its own distinct mode/scene before the puzzle begins.
- The image should be prominent, ideally with zoom/pan capabilities as noted in `docs/identify-phase.md`.
- No level/gameplay elements (like the reef viewport or fish cards) should be visible or interactable during this phase.

## Acceptance notes

- The Identify Phase takes up 100% of the viewport.
- Transition from world map -> Identify Phase -> Puzzle Phase is seamless.
- The UI matches the "Identify the Reef" design intent: prominent image, clear species selection chips, and a definitive "Submit" action.
- "I'm not sure" or skipping should transition directly to the puzzle phase.
