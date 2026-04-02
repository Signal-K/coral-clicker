---
id: tutorial-level0
title: "Tutorial Mission (Level 0)"
status: done
priority: high
labels:
  - gameplay
  - onboarding
  - tutorial
createdAt: '2026-03-16T00:00:00Z'
updatedAt: '2026-03-20T22:51:30Z'
---

# Tutorial Mission — Level 0

## Purpose

Level 0 is a hand-crafted tutorial that teaches the entire game flow before the player encounters real Zooniverse citizen science content. It is NOT based on a Zooniverse image. It has a scripted, fixed composition so nothing unexpected can break the tutorial flow.

Level 0 is NOT a puzzle the player can fail — it guides them to success. No turn limit pressure. No stressors.

---

## Tutorial sequence

The tutorial walks through the core loop step by step, with a tooltip or overlay appearing the **first time each mechanic is encountered**. Once dismissed, tooltips don't repeat.

### Step 1 — Identify phase (guided)

- Full-screen image appears (hand-drawn or placeholder reef — NOT a Zooniverse image)
- Overlay: **"What can you see in this reef? Tap the species you recognise."**
- Only 2 species chips are shown (Madracis sp. + Blue Chromis)
- Player must tap at least one chip
- Overlay: **"Great! Your identification helps real scientists understand this reef."**
- Confirm → transition to puzzle

### Step 2 — Reef viewport introduction

- Overlay: **"This is your reef. Your goal is to grow it to match what you identified."**
- Objective card is highlighted with a pulse: target species shown

### Step 3 — First turn

- Overlay on fish card strip: **"These are your fish. Tap a card to select it."**
- Player taps Blue Chromis card
- Feed overlay icon appears on the reef viewport
- Overlay: **"Tap the Feed icon to add a fish to your reef. It costs Nutrients."**
- Player feeds once; population badge animates
- Overlay: **"Nutrients are your level resource — keep an eye on them."**

### Step 4 — End Turn

- Overlay on Turn Flow strip: **"When you're ready, press End Turn. Coral will grow based on your fish."**
- Player presses End Turn (or nutrients hit 0)
- Turn results panel appears
- Overlay on results panel: **"Here's what happened this turn. Tap Continue when ready."**

### Step 5 — Auto-breeding introduction

- After continuing, an egg appears in the viewport
- Overlay: **"A breeding event! Tap the egg to hatch it, then drag it to a spot in your reef."**
- Player taps egg → hatch animation
- Player drags to zone → population +1

### Step 6 — Win

- After 2-3 turns the reef composition matches target (scripted)
- Level End screen appears
- Overlay: **"You did it! Here's what you earned."** (coins shown — no sync required for tutorial; tutorial coins are free/local)
- Next Level button → unlocks Level 1 → transitions to world map

---

## Fixed composition (scripted)

| Property | Value |
|---|---|
| Target coral | Madracis sp. × 4 |
| Starting fish | Blue Chromis × 2 |
| Starting nutrients | 40 (generous) |
| Turn "limit" | 10 (soft — no fail state) |
| Stressors | None |
| Subject image | Placeholder / hand-drawn |
| Coins reward | 20 (flat; no speed bonus) |

---

## What is NOT in Level 0

- No stressors (introduced first in Level 4 with its own tooltip)
- No environment dials (introduced in Level 3)
- No Zooniverse image (scripted image only)
- No fail state (turns "run out" but tutorial just nudges player to continue)
- No net action (population management not needed at this scale)

---

## Technical

- Scene: reuse `IdentifyPhase.tscn` + `GameScreen.tscn` — no separate tutorial scene
- Tutorial overlay system: `TutorialOverlay.tscn` — displays step text + highlight ring on target node
  - Driven by `tutorial_steps.json` in `res://data/`
  - Overlay dismissed on tap anywhere or auto-advance after 5s
  - `AppController.tutorial_complete: bool` persists to save file; overlays never show again after
- Level 0 entry in `starter_levels.json` with `"is_tutorial": true` flag
  - When `is_tutorial: true`: disable fail state, enable overlay system, use placeholder image
