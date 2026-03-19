# Species Interactions — Kill / Aid Mappings

_Authoritative reference. Derive all game logic from this doc._
_Last updated: 2026-03-16_

## How interactions work

- **Kill** = actor reduces target population by listed amount **per turn** (applied on End Turn)
- **Aid** = actor increases target population growth rate / adds +pop per turn
- Effects are passive — fire automatically on End Turn based on what's present in the reef
- All mappings apply unless marked one-way (→)

## Fish → Coral

| Fish | Target Coral | Effect | Amount/Turn | Notes |
|---|---|---|---|---|
| Parrotfish | Madracis sp. | **Kill** | −2 pop | Bite stony coral polyps |
| Parrotfish | Madrepora sp. | **Kill** | −2 pop | Stony coral grazing |
| Parrotfish | Sponge | Neutral | 0 | Don't target sponges |
| French Angelfish | Sponge | **Kill** | −1 pop | Feed heavily on sponges |
| French Angelfish | All other corals | **Aid** | +1 pop | Sponge removal reduces competition |
| Blue Chromis | All corals | **Aid** | +1 pop | Planktivore; removes planktonic competitors |
| Creole Wrasse | All corals | **Aid** | +1 pop | Same mechanism as Blue Chromis |
| Sergeant Major | All corals | Neutral | 0 | Herbivore farming algae; no direct coral effect |

## Coral → Fish

| Coral | Target Fish | Effect | Notes |
|---|---|---|---|
| Muricea pendula (sea fan) | Blue Chromis | **Aid** +1 pop | Dense sea fans = shelter; increases chromis survival |
| Thesea nivea (sea fan) | Blue Chromis | **Aid** +1 pop | Same shelter mechanism |
| Acanthogorgiidae | Creole Wrasse | **Aid** +1 pop | Gorgonian fans attract plankton (wrasse food) |
| Madracis sp. | Sergeant Major | **Aid** +1 pop | Brain coral structure creates damselfish territory |
| Sponge | French Angelfish | **Aid** +1 pop | Sponge presence attracts angelfish (food) |
| Low coral cover (<25% target) | All fish | **Kill** −1 pop | Insufficient reef structure; habitat loss |

## Environment → Species

| Condition | Species affected | Effect | Notes |
|---|---|---|---|
| Temperature: Warm (>28°C) | Madracis sp. | **Kill** −1/turn | Bleaching threshold |
| Temperature: Warm | Madrepora sp. | **Kill** −1/turn | Same bleaching sensitivity |
| Temperature: Warm | All gorgonians | Neutral | More tolerant of warming |
| Temperature: Cold | Madrepora sp. | **Aid** +1/turn | Deep-water species; prefers cooler |
| Temperature: Cold | Parrotfish | **Kill** −1/turn | Tropical; cold-intolerant |
| Temperature: Cold | Blue Chromis | **Kill** −1/turn | Tropical; cold-intolerant |
| Salinity: Low | Sponge | **Kill** −1/turn | Sensitive to freshwater dilution |
| Salinity: Low | Madracis sp. | **Kill** −1/turn | Stony coral salinity sensitive |
| Salinity: High | All fish | **Kill** −1/turn | Hypersaline stress |
| Salinity: Medium | All species | Neutral | Baseline; no penalty |

## Stressor species (Level 4+)

| Species | Kills | Does NOT kill | Counter |
|---|---|---|---|
| Longspine Sea Urchin | Madracis sp. (−2/turn), Madrepora sp. (−1/turn) | Gorgonians, Sponge | Net it OR introduce Creole Wrasse (urchin predator) |
| Parrotfish (overabundant) | Stony corals | Soft corals, Sponge | Net it OR reduce nutrients to starve population |

## Design notes

- Each interaction has a real ecological basis — discoverable, not arbitrary
- New stressors introduced one at a time (Level 4 = first urchin; Level 6 = second stressor type)
- All effects must be reflected in `species_reference.json` under each species' `interactions` key
- Implementation: load interactions at level start; apply in `_advance_turn()` before results panel
