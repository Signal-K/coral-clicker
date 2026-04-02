---
id: wxmjoe
title: Design water conditions HUD widget (corner of reef viewport)
status: todo
priority: medium
labels:
  - sketch
  - design
createdAt: '2026-03-26T02:31:44.715Z'
updatedAt: '2026-04-02T00:00:00.000Z'
timeSpent: 0
---
# Design water conditions HUD widget (corner of reef viewport)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The reef viewport has a permanent water conditions display in one corner. The elements and states are already settled — what needs designing is how they look.

**Confirmed elements:**
- Thermometer icon — 3 states: Cold / Moderate / Warm
- Salinity droplet icon — 3 states: Low / Medium / High

**What to design:**
- Visual treatment for each state of each icon — specifically what changes between Normal (no penalty), Warning (approaching threshold), Danger (penalty active)
- How the two widgets sit together in the corner without competing
- Whether dangerous states should pulse, change colour, or show a secondary indicator

**Constraints:**
- Sits on top of the reef viewport, so must work over both light (shallow reef) and dark (deep reef) backgrounds
- Palette: deep blue `#1C3561`, off-white `#F0F8FF`, cyan `#00E5FF`, amber `#FFB300` — use these
- Mobile-first, so both widgets combined must fit in a corner ≤ ~80×80dp

Output: a sketch or spec showing the 3 states for each widget + how they sit together. Doesn't need to be pixel-perfect — clear enough for a dev to build from.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 3 visual states defined for thermometer (Cold / Moderate / Warm)
- [ ] #2 3 visual states defined for salinity droplet (Low / Medium / High)
- [ ] #3 Danger state is clearly distinct from Normal at a glance
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
kanban: pbbr01
<!-- SECTION:NOTES:END -->
