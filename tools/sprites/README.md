Sprite Template Engine

Purpose:
- Generate transparent deep-sea pixel art sprites and animation sheets with fixed dimensions.
- Includes starter set for 12 coral species and 5 fish species used by puzzle levels.

Species included:
- Corals: Antipathes atlantica, Antipathes furcata, Bebryce Sp., Ellisellidae, Madracis Sp., Madrepora Sp., Muricea pendula, Acanthogorgiidae, Stichopathes, Swiftia exserta, Thesea nivea, Sponge.
- Fish: Blue Chromis, French Angelfish, Creole Wrasse, Sergeant Major, Parrotfish.

Rules:
- Minimum sprite size is enforced at `64x64`.

Setup:
1. `python3 -m venv .venv`
2. `source .venv/bin/activate`
3. `pip install -r tools/sprites/requirements.txt`

Run:
- `python tools/sprites/generate_sprites.py --out-dir tools/sprites/out --sprite-width 64 --sprite-height 64 --frames 8 --sheet-cols 4`

Outputs:
- `tools/sprites/out/sprites/*.png` (individual frame files)
- `tools/sprites/out/sheets/*_sheet.png` (sprite sheets)
- `tools/sprites/out/meta/*.json` (per-species metadata)
- `tools/sprites/out/meta/species_index.json` (global index)

Research notes:
- `tools/sprites/references/research-notes.md`
