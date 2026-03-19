# Reef Sites — Geographic Themes

_Research notes for world map level theming. Each level is set at a real reef location based on where the featured species actually live._

_Last updated: 2026-03-16_

---

## Species distribution overview

The game's species are primarily **Western Atlantic / Caribbean** in distribution:

| Species | Family | Range |
|---|---|---|
| Antipathes atlantica | Black coral | Caribbean, Gulf of Mexico, W. Atlantic |
| Antipathes furcata | Black coral | Caribbean, S. Florida |
| Bebryce sp. | Gorgonian | Caribbean |
| Ellisellidae (sea whips) | Gorgonian | Caribbean, W. Atlantic |
| Madracis sp. | Stony coral | Caribbean (esp. deeper reefs) |
| Madrepora sp. | Stony coral | Deep-water — Atlantic, Mediterranean |
| Muricea pendula | Gorgonian sea fan | Caribbean |
| Acanthogorgiidae | Gorgonian | Tropical Caribbean |
| Stichopathes | Black coral (wire coral) | Caribbean, tropical Atlantic |
| Swiftia exserta | Gorgonian | Caribbean, Gulf of Mexico |
| Thesea nivea | Gorgonian | Caribbean |
| Sponge | Porifera | Ubiquitous — pan-tropical |
| Blue Chromis | Damselfish | Caribbean |
| Creole Wrasse | Labridae | Caribbean |
| Parrotfish | Scaridae | Caribbean, tropical Atlantic |
| French Angelfish | Pomacanthidae | Caribbean, S. Florida, Gulf of Mexico |
| Sergeant Major | Pomacentridae | Pan-tropical (Caribbean focus) |

**Key insight:** Nearly all featured species co-occur in the Caribbean and tropical W. Atlantic. Geographic theming travels through this region across 10 levels, increasing depth and complexity as the series progresses.

---

## Level site assignments

| Level | Site | Country/Region | Approximate depth | Why this site |
|---|---|---|---|---|
| 0 (Tank) | The Tank | — | — | No location; player's personal reef |
| 1 | Florida Keys NMS | USA (Florida) | Shallow (5–15m) | Beginner-friendly; Madracis + Blue Chromis common; first US coral park |
| 2 | Mesoamerican Barrier Reef | Belize | Shallow-mid (10–20m) | 2nd largest barrier reef; diverse gorgonians |
| 3 | Cayman Wall | Cayman Islands | Mid (20–30m) | Famous wall dives; deeper species begin |
| 4 | Andros Reef | Bahamas | Mid (15–25m) | Long barrier reef; urchin stressor introduced |
| 5 | Grace Bay | Turks & Caicos | Shallow-mid (5–20m) | High diversity; environment mismatch challenge |
| 6 | Bonaire NMP | Bonaire | Mid (10–30m) | Protected reef; competing coral puzzle |
| 7 | Mushroom Forest | Curaçao | Mid-deep (15–40m) | Famous for unusual coral formations; salinity/temp puzzle |
| 8 | Los Roques Archipelago | Venezuela | Deep (30–50m) | Remote, pristine; deep species incl. Madrepora |
| 9 | Fernando de Noronha | Brazil | Mid-deep (15–40m) | Southernmost extent; bleaching event level |
| 10 | Speyside Reef | Trinidad & Tobago | Mid (10–30m) | Biodiversity hotspot; maximum complexity level |

---

## Map art direction

The world map should visually track this journey from the USA down through the Caribbean chain to South America:

- Sites cluster in the NW Caribbean first (Florida → Belize → Cayman → Bahamas)
- Then sweep SE through the Lesser Antilles (Turks → Bonaire → Curaçao)
- Then push further south to Venezuela and Brazil
- Map background: Caribbean Sea / tropical Western Atlantic
- Site 8–10 slightly offset south; map may need to pan/scroll

---

## Data shape updates needed

In `data/world_map_layout.json`, add a `location` field per site:

```json
[
  { "level": 0, "x": 60, "y": 400, "name": "The Tank", "location": null },
  { "level": 1, "x": 140, "y": 220, "name": "Florida Keys", "location": "Florida, USA" },
  { "level": 2, "x": 210, "y": 290, "name": "Belize Barrier Reef", "location": "Belize" },
  { "level": 3, "x": 270, "y": 320, "name": "Cayman Wall", "location": "Cayman Islands" },
  { "level": 4, "x": 310, "y": 260, "name": "Andros Reef", "location": "Bahamas" },
  { "level": 5, "x": 360, "y": 300, "name": "Grace Bay", "location": "Turks & Caicos" },
  { "level": 6, "x": 410, "y": 360, "name": "Bonaire NMP", "location": "Bonaire" },
  { "level": 7, "x": 440, "y": 390, "name": "Mushroom Forest", "location": "Curaçao" },
  { "level": 8, "x": 480, "y": 440, "name": "Los Roques", "location": "Venezuela" },
  { "level": 9, "x": 520, "y": 490, "name": "Fernando de Noronha", "location": "Brazil" },
  { "level": 10, "x": 470, "y": 520, "name": "Speyside Reef", "location": "Trinidad & Tobago" }
]
```

Coordinates are placeholders — adjust to final map art dimensions.
