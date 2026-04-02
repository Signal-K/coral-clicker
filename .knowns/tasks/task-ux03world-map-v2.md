---
id: ux03
title: Design the location spine map (world-progression-v2)
status: todo
priority: high
labels:
  - sketch
  - design
  - map
createdAt: '2026-04-02T00:00:00.000Z'
updatedAt: '2026-04-02T00:00:00.000Z'
assignee: '@Liam'
timeSpent: 0
---
# Design the location spine map (world-progression-v2)

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The world map is getting a v2 redesign: locations instead of flat levels, living reef nodes, daily events surfaced on the map. The structure is settled — design the map.

**The 6 confirmed locations (in order):**

| # | Name | Depth | Water tint | Unlock method |
|---|---|---|---|---|
| 0 | The Nursery | Shallow | Bright turquoise | Always unlocked (tutorial) |
| 1 | Florida Keys | Shallow 5–15m | Clear blue | Progression |
| 2 | Belize Barrier Reef | Mid 15–30m | Deep teal | Progression |
| 3 | Cayman Islands | Mid-deep 30–50m | Blue-grey | Progression |
| 4 | The Bahamas Ledge | Mid 20–40m | Blue | Progression |
| 5 | Bonaire Wall | Deep 50–80m | Dark indigo | Progression |
| 6 | Curaçao Deep | Deep 60–100m | Near-black | Progression |

**Node states:**
- Locked (not yet reachable)
- Available (next on the spine)
- Completed (done — shows animated fish in the node per design doc)
- Daily event active (one event node per day, can appear alongside the spine)

**What to design:**
- Route layout: how the spine reads left→right, top→bottom, or something else
- Node visual treatment: how each location's node reflects its depth/tint identity
- Progression arrows/connectors between nodes
- How the daily event node appears without looking tacked-on
- Where the field guide entry point sits (accessed from the map)

**Constraints:**
- Portrait mobile-first
- Must be readable at a glance: "where am I, what's next, what's locked"
- Background carries personality (not just a grid of icons)
- Palette: `#1C3561` base, `#F0F8FF` text, `#00E5FF` accent, `#FFB300` reward

Output: layout sketch + notes on what each node state looks like. Doesn't need to be detailed — clear enough for a dev to build from and for ux01-reef-route-map decisions to carry over.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Route layout decided (how spine reads)
- [ ] #2 Node states defined for all 4 states (locked / available / completed / daily-event)
- [ ] #3 Daily event node placement decided
<!-- AC:END -->
