# Species Interactions — Kill / Aid Mappings

_This is the authoritative reference for all inter-species effects. Always derive game logic from this doc._

_Last updated: 2026-03-16_

---

## How interactions work

- **Kill** = the actor reduces the target's population by the listed amount **per turn** (applied on End Turn)
- **Aid** = the actor increases the target's population growth rate or adds +pop per turn
- Effects are passive — they fire automatically on End Turn based on what's present in the reef
- All mappings apply symmetrically unless marked one-way (→)

---

## Fish → Coral interactions

| Fish | Target Coral | Effect | Amount/Turn | Notes |
|---|---|---|---|---|
| Parrotfish | Madracis sp. | **Kill** | −2 pop | Parrotfish bite stony coral polyps |
| Parrotfish | Madrepora sp. | **Kill** | −2 pop | Same — stony coral grazing |
| Parrotfish | Sponge | Neutral | 0 | Parrotfish don't target sponges |
| French Angelfish | Sponge | **Kill** | −1 pop | Angelfish feed heavily on sponges |
| French Angelfish | All other corals | **Aid** | +1 pop | Removing sponge reduces competition |
| Blue Chromis | All corals | **Aid** | +1 pop | Planktivore; removes planktonic competitors |
| Creole Wrasse | All corals | **Aid** | +1 pop | Planktivore; same mechanism as chromis |
| Sergeant Major | All corals | Neutral | 0 | Herbivore farming algae patches; no direct coral effect |

---

## Coral → Fish interactions

| Coral | Target Fish | Effect | Notes |
|---|---|---|---|
| Muricea pendula (sea fan) | Blue Chromis | **Aid** +1 pop | Dense sea fans provide shelter; increases chromis survival |
| Thesea nivea (sea fan) | Blue Chromis | **Aid** +1 pop | Same shelter mechanism |
| Acanthogorgiidae | Creole Wrasse | **Aid** +1 pop | Gorgonian fans attract plankton — wrasse food source |
| Madracis sp. | Sergeant Major | **Aid** +1 pop | Brain coral structure creates territory for damselfish |
| Sponge | French Angelfish | **Aid** +1 pop | Sponge presence attracts angelfish (food source) |
| Low coral cover (<25% target) | All fish | **Kill** −1 pop | Insufficient reef structure; habitat loss |

---

## Environment → Species interactions

| Condition | Species affected | Effect | Notes |
|---|---|---|---|
| Temperature: Warm (>28°C equivalent) | Madracis sp. | **Kill** −1/turn | Bleaching threshold — stony coral sensitive |
| Temperature: Warm | Madrepora sp. | **Kill** −1/turn | Same bleaching sensitivity |
| Temperature: Warm | All gorgonians (Muricea, Thesea, Swiftia, etc.) | Neutral | More tolerant of warming |
| Temperature: Cold | Madrepora sp. | **Aid** +1/turn | Deep-water species; prefers cooler |
| Temperature: Cold | Parrotfish | **Kill** −1/turn | Tropical fish; cold-intolerant |
| Temperature: Cold | Blue Chromis | **Kill** −1/turn | Same — tropical fish |
| Salinity: Low | Sponge | **Kill** −1/turn | Sponges sensitive to freshwater dilution |
| Salinity: Low | Madracis sp. | **Kill** −1/turn | Stony coral salinity sensitive |
| Salinity: High | All fish | **Kill** −1/turn | Hypersaline stress on most reef fish |
| Salinity: Medium | All species | Neutral/optimal | Baseline — no penalty |

---

## Stressor species (for Level 4+)

These are species that function primarily as threats. They auto-breed and compound if ignored.

| Species | Kills | Does NOT kill | Counter |
|---|---|---|---|
| Longspine Sea Urchin | Madracis sp. (−2/turn), Madrepora sp. (−1/turn) | Gorgonians, sponge | Net it (uses net charge) or introduce Creole Wrasse (urchin predator) |
| Parrotfish (when overabundant) | Stony corals | Soft corals, sponge | Net it or reduce nutrients to starve population |

---

## "Kill a coral" puzzle mechanic (Level 6+)

Some levels require a coral that you must eventually REMOVE from the final reef. Strategy:

1. Grow a helper coral (e.g. Sponge) to attract a fish you need (e.g. French Angelfish)
2. Use that fish to boost other corals toward your target
3. Use Parrotfish or a stressor to eliminate the helper coral
4. Net the Parrotfish once helper is gone
5. Win with target composition only

This emergent loop is the core mid-to-late puzzle mechanic. Levels 6–10 are designed around it.

---

## Design notes

- Interactions should feel discoverable, not arbitrary — each one has a real ecological basis
- New stressors introduced one at a time (Level 4 = first urchin; Level 6 = second stressor type)
- All effects listed here must be reflected in `project/data/species_reference.json` under each species' `interactions` key
- When implementing: load interactions from species_reference.json at level start; apply effects in `_advance_turn()` before showing results panel
