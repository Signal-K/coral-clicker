---
id: gp09traits
title: "Trait system — research, design, and implementation"
status: todo
priority: medium
labels:
  - gameplay
  - breeding
  - content
  - research
createdAt: '2026-03-17T00:00:00Z'
updatedAt: '2026-03-17T00:00:00Z'
---

# Trait system — research, design, and implementation

## Phase 1: Research (before build)

Research and document the **real ecological traits** for each root species in the game. Each species should have 1–3 pre-determined traits grounded in Caribbean reef biology.

### Species to research traits for

**Fish:**
- Blue Chromis (*Chromis cyanea*)
- Creole Wrasse (*Clepticus parrae*)
- Parrotfish (e.g. *Sparisoma viride*)
- French Angelfish (*Pomacanthus paru*)
- Sergeant Major (*Abudefduf saxatilis*)

**Coral:**
- Madracis sp. (branching stony coral)
- Madrepora sp. (deep stony coral)
- Muricea pendula (sea fan)
- Thesea nivea (white sea fan)
- Acanthogorgiidae (gorgonian)
- Antipathes atlantica / furcata (black coral)
- Bebryce sp. (gorgonian)
- Ellisellidae (sea whip)
- Stichopathes (wire coral)
- Swiftia exserta (purple sea plume)
- Sponge

### Trait types (draft — confirm with research)

Good traits: `heat_tolerant`, `cold_specialist`, `fast_breeder`, `urchin_predator`, `algae_grazer`, `schooling_bonus`, `deep_diver`, `current_adapted`

Bad traits: `heat_sensitive`, `stony_coral_threat`, `territory_marker`, `low_salinity_sensitive`, `overcrowding_stress`

Document findings in `project/data/species_reference.json` under `species_traits` field for each species.

## Phase 2: Inheritance mechanics

### Root species
- Fixed, pre-determined trait set (from Phase 1 research)
- Cannot change through gameplay

### Bred offspring (same species × same species)
- Inherits parent traits (Mendelian probability: each trait has a chance to pass or not)
- Small chance to gain a **bonus trait** (good or bad) beyond inherited pool
- Does NOT create a new species (same species name retained)

### Bred offspring (mixed species)
- Combines trait pool from both parents
- Higher chance of bonus traits (greater genetic diversity = more variation)
- Creates a **new species** — player names it

### New species creation
- Player is prompted for a name when a new species is created for the first time
- Name is saved to save file; used in card strip and results panel
- **REMINDER (2026-03-31):** Future sprint — player customises faces/colours for new species from a mix-and-match defined list (see task-future-v02species-creator.md)

## Phase 3: Breeding preview dialog

Show before committing a breed pairing:
- Parent A traits (with icons)
- Parent B traits (with icons)
- Likely outcome traits (probability-weighted list for the offspring)
- Whether a new species would result
- Confirm / Cancel buttons

## Technical

- `trait_definitions` array in `species_reference.json`: `{ id, name, description, effect_type, delta_value }`
- `species_traits` per species: array of trait IDs
- Breeding resolution in `level_system.gd`: `_resolve_breeding(parent_a, parent_b)` → returns offspring trait array
- New species saved to `AppController.custom_species: Dictionary`

## Design reference

See [docs/breeding.md](../docs/breeding.md) — "Trait system" section.
