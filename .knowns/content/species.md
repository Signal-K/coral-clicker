# Species Reference

_Full specs (temperature, salinity, depth, traits, interactions): `project/data/species_reference.json`_
_Kill/aid gameplay mappings: [docs/interactions.md](../docs/interactions.md)_

## Corals — 12 species

| Species | Common name | Family | Range |
|---|---|---|---|
| Antipathes atlantica | Black coral | Antipathidae | Caribbean, Gulf of Mexico, W. Atlantic |
| Antipathes furcata | Black coral | Antipathidae | Caribbean, S. Florida |
| Bebryce sp. | Gorgonian | Plexauridae | Caribbean |
| Ellisellidae | Sea whips | Ellisellidae | Caribbean, W. Atlantic |
| Madracis sp. | Stony coral | Pocilloporidae | Caribbean (esp. deeper reefs) |
| Madrepora sp. | Stony coral | Oculinidae | Deep-water — Atlantic, Mediterranean |
| Muricea pendula | Gorgonian sea fan | Plexauridae | Caribbean |
| Acanthogorgiidae | Gorgonian | Acanthogorgiidae | Tropical Caribbean |
| Stichopathes | Wire coral (black coral) | Antipathidae | Caribbean, tropical Atlantic |
| Swiftia exserta | Gorgonian | Plexauridae | Caribbean, Gulf of Mexico |
| Thesea nivea | Gorgonian | Plexauridae | Caribbean |
| Sponge | Sponge | Porifera | Pan-tropical (ubiquitous) |

## Fish — 5 species + stressors

| Species | Common name | Family | Range |
|---|---|---|---|
| Blue Chromis | Blue Chromis | Pomacentridae | Caribbean |
| Creole Wrasse | Creole Wrasse | Labridae | Caribbean |
| Parrotfish | Parrotfish | Scaridae | Caribbean, tropical Atlantic |
| French Angelfish | French Angelfish | Pomacanthidae | Caribbean, S. Florida, Gulf of Mexico |
| Sergeant Major | Sergeant Major | Pomacentridae | Pan-tropical (Caribbean focus) |

## Stressor species

| Species | Type | Kills |
|---|---|---|
| Longspine Sea Urchin | Stressor (Level 4+) | Madracis sp. −2/turn, Madrepora sp. −1/turn |
| Parrotfish (overabundant) | Stressor (Level 6+) | Stony corals −2/turn |

## Environment preferences (summary)

| Species | Prefers | Dislikes |
|---|---|---|
| Madracis sp. | Medium temp, medium salinity | Warm (bleach), cold salinity |
| Madrepora sp. | Cold temp, medium salinity | Warm (bleach), any salinity extreme |
| All gorgonians | Any temp | No strong preferences |
| Parrotfish | Warm temp | Cold (−1/turn) |
| Blue Chromis | Warm temp | Cold (−1/turn) |
| Sponge | Medium salinity | Low salinity (−1/turn) |
| All fish | Medium salinity | High salinity (−1/turn) |

For full depth, temperature, and salinity ranges: `project/data/species_reference.json`.
