---
id: onb04-identify-trustworthiness
title: "Fix identify-phase trust for first-time players"
status: done
priority: urgent
labels:
  - onboarding
  - identify
  - ux
createdAt: '2026-03-20T00:00:00Z'
updatedAt: '2026-03-21T03:29:03Z'
---

# Fix identify-phase trust for first-time players

## Problem

The identify step is still confusing in the tutorial path.

Observed issues:
- tutorial capture showed an image that does not read clearly as a real reef reference
- the choice set can feel disconnected from the displayed image
- a first-time player cannot tell whether they are classifying a real image, a stylized proxy, or placeholder content

## Why this is urgent

This is the very first interaction in the game loop.
If it feels arbitrary or wrong, the player stops trusting the rest of the system.

## Required outcome

- Tutorial/fresh-player identify prompt must use imagery that clearly reads as the intended subject
- Species choices must visibly make sense against the shown image
- If the data is synthetic or curated, the UX must still feel deliberate and trustworthy

## Acceptance notes

- First-run identify screen should be understandable without prior reef knowledge
- A player should not feel like they are guessing against junk data
- No obvious mismatch between subject image and species options
