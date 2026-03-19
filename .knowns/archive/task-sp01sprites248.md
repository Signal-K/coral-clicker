---
id: sp01sprites248
title: "Regenerate sprites at 248×248px"
status: done
priority: critical
labels:
  - sprites
  - art
  - blocking
createdAt: '2026-03-15T00:00:00Z'
updatedAt: '2026-03-15T00:00:00Z'
---

# Regenerate sprites at 248×248px

## Why first

Every other visual task depends on correct sprite sizes. Do this before any UI layout work.

## Requirements

- Update `tools/sprites/generate_sprites.py` canvas size from 128×128 to 248×248
- Scale up all drawing operations proportionally (multiply all pixel coordinates by ~1.94)
- Regenerate all 17 species × 8 frames = 136 PNGs into `project/assets/sprites/`
- Overwrite existing `_frame_00` through `_frame_07` files for all species
- Update all `.import` files (delete old ones; Godot will re-import on next open)
- Update `SpriteFrames` .tres files — no change needed (they reference by path, not size)
- Update `ReefViewport.tscn` AnimatedSprite2D scales: 248px base → adjust scale to match desired display sizes

## Display size targets (after scale)

| Context | Display size | Scale | Art pass |
|---|---|---|---|
| Reef fish (FishSwim) | ~90px | 0.36 | Standard |
| Reef coral (Coral1/2/3) | ~120px | 0.48 | Standard |
| Fish card strip | ~72px | 0.29 | **Separate art pass** |

**Separate art pass for fish card strip:** Card strip sprites are viewed at small size in portrait portrait mode and need to read clearly at 72px. Create a distinct set optimised for small display — simplified silhouettes, stronger colour contrast, same species identity. Store as `{species}_card_frame_00..07.png` alongside standard frames.

## Directional variants

Fish sprites must face the correct direction based on their swim path. Do NOT use GDScript `.flip_h` mirroring. Instead:
- Create distinct animation states in the **Godot AnimationPlayer** for left-facing and right-facing
- The animation system handles flipping via AnimationPlayer keyframes, not code
- Coral sprites are stationary — no directional concern

## Technical notes

- Only change canvas size and coordinate scaling in the Python script
- Preserve all species-specific colours, shapes, morphology logic
- Run: `python3 tools/sprites/generate_sprites.py`
- Then in Godot: Project → Reimport All
