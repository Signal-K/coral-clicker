---
id: onb01-first-run-tutorial
title: "First-run interactive tutorial"
status: in_progress
priority: high
labels:
  - onboarding
  - gameplay
  - tutorial
createdAt: '2026-03-19T00:00:00Z'
updatedAt: '2026-03-19T00:00:00Z'
---

# First-run interactive tutorial

## Product direction

The tutorial exists to help a new player understand the game loop quickly. It is **not** a citizen-science explainer and it does **not** need narrative lore.

The answer to "why am I doing this?" is simply: **because this is a fun reef-building puzzle game**.

## Core teaching goals

Teach only the minimum loop needed to play:
1. Identify what you can see in the reef image
2. Understand the target reef / success condition
3. Feed fish to change the reef
4. End the turn to resolve growth
5. Read the turn results
6. Win a level

## Rules

- First-run only; driven by `AppController.tutorial_complete`
- Interactive, not passive text dump
- No Supabase/offline/sync explanation to the player
- Avoid ecology jargon where plain game language works
- Defer stressors, extinction, and advanced environment tuning until those mechanics actually appear

## Current build direction

- Implement on the live Level 1 path first
- Use `TutorialOverlay.tscn` + `tutorial_steps.json`
- Gate steps off real player actions (identify confirm, first feed, first end turn, first results panel, first win)
