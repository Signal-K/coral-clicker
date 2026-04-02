# Breeding And Traits

## Current system

- Each root species has a fixed trait pool in [species_reference.json](/Users/scroobz/Navigation/Coral/project/data/species_reference.json).
- Breeding preview already shows parent pair, nutrient cost, success chance, possible offspring, and possible inherited traits.
- Successful offspring keep the species name for now and can inherit one trait from the parent/offspring pool.

## Root-species research summary

### Fish

- `Blue Chromis`: `schooling`, `warm_tolerant`
- `French Angelfish`: `reef_cleaner`, `warm_tolerant`
- `Creole Wrasse`: `cold_resistant`, `deep_adapted`
- `Sergeant Major`: `fast_breeder`, `schooling`
- `Parrotfish`: `algae_control`, `bioerosion`

### Coral and reef builders

- `Madracis Sp.`: `warm_tolerant`, `reef_cleaner`
- `Madrepora Sp.`: `deep_adapted`, `slow_breeder`
- `Muricea pendula`: `reef_cleaner`, `schooling`
- `Thesea nivea`: `reef_cleaner`, `warm_tolerant`
- `Acanthogorgiidae`: `deep_adapted`
- `Antipathes atlantica`: `deep_adapted`, `cold_resistant`
- `Antipathes furcata`: `deep_adapted`, `cold_resistant`
- `Bebryce Sp.`: `reef_cleaner`
- `Ellisellidae`: `schooling`
- `Stichopathes`: `deep_adapted`, `cold_resistant`
- `Swiftia exserta`: `deep_adapted`, `schooling`
- `Sponge`: `fast_breeder`

## Trait meanings

- `fast_breeder`: lowers breeding cost and raises success chance
- `slow_breeder`: slightly lowers breeding success
- `reef_cleaner`: adds a flat support bonus
- `algae_control`: adds a support bonus that reads as algae suppression
- `schooling`: grants extra support once the population threshold is reached
- `cold_resistant`: improves support for cooler/deeper targets
- `warm_tolerant`: improves support for warm shallow targets
- `deep_adapted`: improves support for deep reef targets
- `bioerosion`: trades some sponge pressure for substrate reset utility

## Inheritance notes

- Current implementation gives successful offspring a 60% chance to inherit one trait from the combined parent/offspring trait pool.
- The preview dialog surfaces that pool before commit so the player can make a readable decision.
- Mixed-species naming/custom-species creation is still deferred; the current build keeps the existing species name.
