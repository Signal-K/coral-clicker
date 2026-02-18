#!/usr/bin/env python3

import argparse
import json
import math
import os
from dataclasses import dataclass
from typing import Dict, List, Tuple

from PIL import Image, ImageDraw


Color = Tuple[int, int, int, int]


@dataclass
class SpriteSpec:
    slug: str
    display_name: str
    category: str
    shape: str
    primary: Color
    secondary: Color


CORAL_SPECS: List[SpriteSpec] = [
    SpriteSpec("antipathes_atlantica", "Antipathes atlantica", "coral", "black_coral_branch", (24, 20, 24, 255), (70, 55, 58, 255)),
    SpriteSpec("antipathes_furcata", "Antipathes furcata", "coral", "black_coral_whip", (32, 24, 30, 255), (78, 62, 66, 255)),
    SpriteSpec("bebryce_sp", "Bebryce Sp.", "coral", "soft_branch", (199, 150, 180, 255), (229, 204, 220, 255)),
    SpriteSpec("ellisellidae", "Ellisellidae", "coral", "fan", (245, 151, 92, 255), (255, 210, 170, 255)),
    SpriteSpec("madracis_sp", "Madracis Sp.", "coral", "stony_cluster", (122, 185, 117, 255), (179, 230, 172, 255)),
    SpriteSpec("madrepora_sp", "Madrepora Sp.", "coral", "stony_branch", (146, 171, 207, 255), (205, 226, 255, 255)),
    SpriteSpec("muricea_pendula", "Muricea pendula", "coral", "fan", (210, 116, 95, 255), (244, 185, 160, 255)),
    SpriteSpec("acanthogorgiidae", "Acanthogorgiidae", "coral", "soft_branch", (155, 108, 184, 255), (214, 176, 236, 255)),
    SpriteSpec("stichopathes", "Stichopathes", "coral", "black_coral_whip", (20, 24, 20, 255), (70, 82, 66, 255)),
    SpriteSpec("swiftia_exserta", "Swiftia exserta", "coral", "fan", (255, 137, 102, 255), (255, 200, 166, 255)),
    SpriteSpec("thesea_nivea", "Thesea nivea", "coral", "soft_branch", (232, 230, 224, 255), (250, 248, 243, 255)),
    SpriteSpec("sponge", "Sponge", "coral", "sponge", (246, 168, 75, 255), (255, 219, 156, 255)),
]

FISH_SPECS: List[SpriteSpec] = [
    SpriteSpec("blue_chromis", "Blue Chromis", "fish", "fish_damselfish", (66, 183, 246, 255), (143, 228, 255, 255)),
    SpriteSpec("french_angelfish", "French Angelfish", "fish", "fish_angelfish", (66, 70, 76, 255), (240, 210, 110, 255)),
    SpriteSpec("creole_wrasse", "Creole Wrasse", "fish", "fish_wrasse", (99, 118, 163, 255), (163, 192, 255, 255)),
    SpriteSpec("sergeant_major", "Sergeant Major", "fish", "fish_striped", (240, 229, 148, 255), (43, 58, 70, 255)),
    SpriteSpec("parrotfish", "Parrotfish", "fish", "fish_parrot", (52, 195, 153, 255), (120, 246, 214, 255)),
]


def clamp(v: int, lo: int, hi: int) -> int:
    return max(lo, min(hi, v))


def draw_branch(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int) -> None:
    cx = w // 2
    y_base = int(h * 0.86)
    y_top = int(h * 0.26)
    sway = int(math.sin(frame * 0.55) * (w * 0.03))
    offsets = [-0.22, -0.14, -0.06, 0.0, 0.08, 0.16, 0.24]

    for i, offset in enumerate(offsets):
        x0 = int(cx + offset * w) + sway
        t = i / max(1, len(offsets) - 1)
        arc = int(math.sin((t * math.pi) + frame * 0.2) * (w * 0.04))
        x1 = x0 + arc
        y1 = y_top + int((i % 3) * (h * 0.05))
        draw.line((x0, y_base, x1, y1), fill=spec.primary, width=2)
        draw.ellipse((x1 - 1, y1 - 1, x1 + 1, y1 + 1), fill=spec.secondary)

    draw.ellipse((cx - int(w * 0.08), y_base - int(h * 0.1), cx + int(w * 0.08), y_base), fill=spec.primary)


def draw_fan(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int) -> None:
    ox = w // 2 + int(math.sin(frame * 0.4) * (w * 0.03))
    oy = int(h * 0.86)
    radius = int(w * 0.33)

    for angle in range(-70, 71, 10):
        rad = math.radians(angle)
        x1 = ox + int(math.cos(rad) * radius)
        y1 = oy - int(abs(math.sin(rad)) * int(h * 0.62))
        draw.line((ox, oy, x1, y1), fill=spec.primary, width=2)

    for step in [0.25, 0.45, 0.65, 0.85]:
        y = oy - int(step * h * 0.55)
        width = int((1.0 - step * 0.7) * radius)
        draw.arc((ox - width, y - int(h * 0.03), ox + width, y + int(h * 0.03)), 200, 340, fill=spec.secondary, width=1)


def draw_stony(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, branching: bool) -> None:
    cx = w // 2
    base_y = int(h * 0.82)

    if branching:
        stalk_offsets = [-0.18, -0.06, 0.06, 0.18]
        for i, offset in enumerate(stalk_offsets):
            x = int(cx + offset * w)
            sway = int(math.sin(frame * 0.5 + i) * (w * 0.02))
            draw.rounded_rectangle((x - int(w * 0.06), int(h * 0.38), x + int(w * 0.06), base_y), radius=3, fill=spec.primary)
            draw.ellipse((x - int(w * 0.07) + sway, int(h * 0.28), x + int(w * 0.07) + sway, int(h * 0.44)), fill=spec.secondary)
    else:
        draw.ellipse((int(w * 0.18), int(h * 0.34), int(w * 0.82), base_y), fill=spec.primary)
        for i in range(6):
            px = int(w * (0.27 + i * 0.09))
            py = int(h * (0.42 + (i % 2) * 0.08))
            draw.ellipse((px - 2, py - 2, px + 2, py + 2), fill=spec.secondary)


def draw_whip(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int) -> None:
    cx = w // 2
    y_base = int(h * 0.9)
    points = []
    for i in range(14):
        t = i / 13.0
        y = int(y_base - t * h * 0.72)
        x = int(cx + math.sin((t * 2.2) + frame * 0.45) * (w * (0.05 + t * 0.07)))
        points.append((x, y))

    draw.line(points, fill=spec.primary, width=3)
    for idx in range(2, len(points), 3):
        x, y = points[idx]
        draw.ellipse((x - 1, y - 1, x + 1, y + 1), fill=spec.secondary)


def draw_sponge(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int) -> None:
    wobble = int(math.sin(frame * 0.6) * (w * 0.02))
    draw.rounded_rectangle((int(w * 0.24) + wobble, int(h * 0.3), int(w * 0.76) + wobble, int(h * 0.84)), radius=8, fill=spec.primary)
    holes = [
        (0.38, 0.45, 0.04),
        (0.56, 0.50, 0.05),
        (0.46, 0.63, 0.06),
    ]
    for hx, hy, hr in holes:
        x = int(w * hx) + wobble
        y = int(h * hy)
        r = int(w * hr)
        draw.ellipse((x - r, y - r, x + r, y + r), fill=spec.secondary)


def draw_fish(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int) -> None:
    swim = int(math.sin(frame * 0.7) * (w * 0.025))
    cx = w // 2 + swim
    cy = h // 2

    body_w = int(w * 0.5)
    body_h = int(h * 0.3)

    if spec.shape == "fish_angelfish":
        body_w = int(w * 0.42)
        body_h = int(h * 0.36)
    elif spec.shape == "fish_wrasse":
        body_w = int(w * 0.58)
        body_h = int(h * 0.24)
    elif spec.shape == "fish_parrot":
        body_w = int(w * 0.55)
        body_h = int(h * 0.31)

    draw.ellipse((cx - body_w // 2, cy - body_h // 2, cx + body_w // 2, cy + body_h // 2), fill=spec.primary)

    tail_dx = int(w * 0.18)
    tail = [
        (cx - body_w // 2, cy),
        (cx - body_w // 2 - tail_dx, cy - body_h // 3),
        (cx - body_w // 2 - tail_dx, cy + body_h // 3),
    ]
    draw.polygon(tail, fill=spec.secondary)

    fin = [
        (cx - int(body_w * 0.05), cy - body_h // 2),
        (cx + int(body_w * 0.18), cy - body_h // 2 - int(h * 0.08)),
        (cx + int(body_w * 0.3), cy - body_h // 2),
    ]
    draw.polygon(fin, fill=spec.secondary)

    if spec.shape in ("fish_striped", "fish_angelfish"):
        for i in range(3):
            x = cx - int(body_w * 0.2) + i * int(body_w * 0.2)
            draw.line((x, cy - body_h // 2 + 2, x, cy + body_h // 2 - 2), fill=spec.secondary, width=2)

    if spec.shape == "fish_parrot":
        beak = [
            (cx + body_w // 2 - 1, cy),
            (cx + body_w // 2 + int(w * 0.08), cy - int(h * 0.03)),
            (cx + body_w // 2 + int(w * 0.06), cy + int(h * 0.05)),
        ]
        draw.polygon(beak, fill=spec.secondary)

    eye_x = cx + int(body_w * 0.2)
    eye_y = cy - int(body_h * 0.2)
    draw.ellipse((eye_x - 2, eye_y - 2, eye_x + 2, eye_y + 2), fill=(255, 255, 255, 255))
    draw.point((eye_x, eye_y), fill=(0, 0, 0, 255))


def draw_sprite(spec: SpriteSpec, width: int, height: int, frame: int) -> Image.Image:
    image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    if spec.category == "fish":
        draw_fish(draw, width, height, spec, frame)
    elif spec.shape in ("soft_branch", "black_coral_branch"):
        draw_branch(draw, width, height, spec, frame)
    elif spec.shape == "fan":
        draw_fan(draw, width, height, spec, frame)
    elif spec.shape == "stony_cluster":
        draw_stony(draw, width, height, spec, frame, False)
    elif spec.shape == "stony_branch":
        draw_stony(draw, width, height, spec, frame, True)
    elif spec.shape == "black_coral_whip":
        draw_whip(draw, width, height, spec, frame)
    else:
        draw_sponge(draw, width, height, spec, frame)

    return image


def build_sheet(frames: List[Image.Image], cols: int, width: int, height: int) -> Image.Image:
    rows = math.ceil(len(frames) / cols)
    sheet = Image.new("RGBA", (cols * width, rows * height), (0, 0, 0, 0))
    for idx, frame in enumerate(frames):
        x = (idx % cols) * width
        y = (idx // cols) * height
        sheet.paste(frame, (x, y), frame)
    return sheet


def ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def write_species_index(out_dir: str, specs: List[SpriteSpec], width: int, height: int, frames: int, columns: int) -> None:
    index = {
        "sprite_width": width,
        "sprite_height": height,
        "frames": frames,
        "columns": columns,
        "transparent_background": True,
        "species": [
            {
                "slug": s.slug,
                "name": s.display_name,
                "category": s.category,
                "shape": s.shape,
                "sheet": f"sheets/{s.slug}_sheet.png",
            }
            for s in specs
        ],
    }
    with open(os.path.join(out_dir, "meta", "species_index.json"), "w", encoding="utf-8") as fp:
        json.dump(index, fp, indent=2)


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate transparent deep-sea species sprites and sprite sheets.")
    parser.add_argument("--out-dir", default="tools/sprites/out", help="Output directory")
    parser.add_argument("--sprite-width", type=int, default=64)
    parser.add_argument("--sprite-height", type=int, default=64)
    parser.add_argument("--frames", type=int, default=8)
    parser.add_argument("--sheet-cols", type=int, default=4)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    if args.sprite_width < 64 or args.sprite_height < 64:
        raise ValueError("Sprite dimensions must be at least 64x64.")

    random_seed = args.seed
    # Keep deterministic output across runs while still allowing CLI seed variance.
    # Frame motion is procedural (sinusoidal), not random drift.
    _ = random_seed

    sprite_dir = os.path.join(args.out_dir, "sprites")
    sheet_dir = os.path.join(args.out_dir, "sheets")
    meta_dir = os.path.join(args.out_dir, "meta")

    ensure_dir(sprite_dir)
    ensure_dir(sheet_dir)
    ensure_dir(meta_dir)

    specs = CORAL_SPECS + FISH_SPECS

    for spec in specs:
        frames: List[Image.Image] = []
        for frame in range(args.frames):
            frames.append(draw_sprite(spec, args.sprite_width, args.sprite_height, frame))

        for idx, frame in enumerate(frames):
            frame.save(os.path.join(sprite_dir, f"{spec.slug}_frame_{idx:02d}.png"))

        sheet = build_sheet(frames, args.sheet_cols, args.sprite_width, args.sprite_height)
        sheet_path = os.path.join(sheet_dir, f"{spec.slug}_sheet.png")
        sheet.save(sheet_path)

        metadata: Dict[str, object] = {
            "slug": spec.slug,
            "name": spec.display_name,
            "category": spec.category,
            "shape": spec.shape,
            "width": args.sprite_width,
            "height": args.sprite_height,
            "frames": args.frames,
            "columns": args.sheet_cols,
            "sheet": os.path.relpath(sheet_path, args.out_dir),
            "transparent_background": True,
        }

        with open(os.path.join(meta_dir, f"{spec.slug}.json"), "w", encoding="utf-8") as fp:
            json.dump(metadata, fp, indent=2)

    write_species_index(args.out_dir, specs, args.sprite_width, args.sprite_height, args.frames, args.sheet_cols)
    print(f"Generated {len(specs)} species sprite sets in: {args.out_dir}")


if __name__ == "__main__":
    main()
