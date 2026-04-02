---
id: qp0w5k
title: Design the bleaching event experience (notification + in-level state)
status: todo
priority: medium
labels:
  - sketch
  - design
createdAt: '2026-03-26T02:31:45.305Z'
updatedAt: '2026-04-02T00:00:00.000Z'
timeSpent: 0
---
# Design the bleaching event experience (notification + in-level state)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bleaching is a daily event type (world-progression-v2). When active, the game mechanics shift in a defined way — what's needed is how the player *experiences* that.

**What the game already does during a bleaching event:**
- Water tint washes pale (coral sprites desaturate — engineering handles this)
- Temperature forced +1 warm each turn unless the player spends coins on the dial
- Stony corals take extra damage while warm threshold is exceeded
- Event lasts the duration of the level

**Two moments to design:**

1. **Entry beat** — Player taps into a level and a bleaching event is active. How do they learn this before the turn clock starts? Options: a banner/toast, a brief overlay with dismiss, ambient change only (no explicit notice). What's the right tone — alarming vs informational?

2. **In-level indicator** — Something persistent that tells the player "bleaching is still active" without nagging. Could be the corner HUD widget (wxmjoe) in danger state, a border treatment on the viewport, or nothing (the desaturated visual is enough). What's the minimum signal?

The entry beat and in-level indicator don't need to be elaborate — the ecological stakes are real and the tone should reflect that without being preachy. Design for the player who wants to know what's happening, not the player who needs it explained.

Output: sketch or written spec for both moments. Covers bleaching only (restoration milestones are a separate concern).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Entry beat designed (what shows, how player dismisses, tone)
- [ ] #2 In-level persistent indicator decided (or explicitly ruled out with reason)
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
kanban: uw3lor
<!-- SECTION:NOTES:END -->
