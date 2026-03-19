#!/usr/bin/env python3
"""
Generate 248x248 pixel art sprites for all Coral Clicker species.
Each species has a unique drawing function with accurate morphology and color.
"""

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
    tertiary: Color = (0, 0, 0, 0)


# Accurate colors from species reference research
CORAL_SPECS: List[SpriteSpec] = [
    # Antipathes atlantica — dark mesh fan, nearly black with slight brown tinge
    SpriteSpec("antipathes_atlantica", "Antipathes atlantica", "coral", "black_coral_fan",
               (30, 22, 28, 255), (58, 46, 52, 255), (90, 72, 80, 255)),
    # Antipathes furcata — dark brown-grey Y-branching whip
    SpriteSpec("antipathes_furcata", "Antipathes furcata", "coral", "forked_coral",
               (40, 32, 36, 255), (75, 62, 68, 255), (110, 92, 100, 255)),
    # Bebryce Sp. — golden-yellow branching bush
    SpriteSpec("bebryce_sp", "Bebryce Sp.", "coral", "golden_bush",
               (210, 165, 40, 255), (240, 200, 80, 255), (255, 230, 140, 255)),
    # Ellisellidae — vivid orange-red tall whip with white polyp dots
    SpriteSpec("ellisellidae", "Ellisellidae", "coral", "sea_whip",
               (220, 80, 30, 255), (255, 130, 60, 255), (255, 248, 240, 255)),
    # Madracis Sp. — bright yellow pencil-finger branches
    SpriteSpec("madracis_sp", "Madracis Sp.", "coral", "pencil_coral",
               (230, 210, 20, 255), (255, 240, 80, 255), (200, 180, 10, 255)),
    # Madrepora Sp. — pale pink fine branching with alternating bumps
    SpriteSpec("madrepora_sp", "Madrepora Sp.", "coral", "zigzag_coral",
               (230, 170, 180, 255), (255, 210, 220, 255), (200, 130, 145, 255)),
    # Muricea pendula — amber-yellow pinnate (feather) fan
    SpriteSpec("muricea_pendula", "Muricea pendula", "coral", "pinnate_fan",
               (190, 140, 40, 255), (220, 175, 80, 255), (240, 205, 120, 255)),
    # Acanthogorgiidae — orange with dark axis, bristly polyps
    SpriteSpec("acanthogorgiidae", "Acanthogorgiidae", "coral", "spiky_gorgonian",
               (220, 100, 30, 255), (50, 30, 20, 255), (255, 200, 150, 255)),
    # Stichopathes — single spiralling wire, dark, one-sided white polyps
    SpriteSpec("stichopathes", "Stichopathes", "coral", "wire_coral",
               (25, 22, 25, 255), (60, 52, 58, 255), (240, 240, 240, 255)),
    # Swiftia exserta — vivid orange tree with red-dot polyps
    SpriteSpec("swiftia_exserta", "Swiftia exserta", "coral", "orange_tree",
               (240, 90, 20, 255), (200, 40, 10, 255), (255, 160, 80, 255)),
    # Thesea nivea — red-purple body with distinctive white eye-like polyps
    SpriteSpec("thesea_nivea", "Thesea nivea", "coral", "white_eye_fan",
               (160, 45, 90, 255), (200, 70, 120, 255), (250, 248, 248, 255)),
    # Sponge (barrel) — reddish-brown barrel with open top and ridges
    SpriteSpec("sponge", "Sponge", "coral", "barrel_sponge",
               (160, 80, 55, 255), (200, 110, 75, 255), (80, 38, 22, 255)),
]

FISH_SPECS: List[SpriteSpec] = [
    # Blue Chromis — electric blue, black dorsal stripe, deeply forked tail
    SpriteSpec("blue_chromis", "Blue Chromis", "fish", "fish_chromis",
               (40, 160, 240, 255), (20, 80, 180, 255), (100, 210, 255, 255)),
    # French Angelfish — black disc, golden scale-edge dots, orange pectoral
    SpriteSpec("french_angelfish", "French Angelfish", "fish", "fish_angelfish",
               (30, 30, 35, 255), (200, 165, 30, 255), (210, 110, 20, 255)),
    # Creole Wrasse — purple elongate, dark snout, deep-V tail
    SpriteSpec("creole_wrasse", "Creole Wrasse", "fish", "fish_wrasse",
               (115, 70, 160, 255), (25, 18, 30, 255), (190, 140, 220, 255)),
    # Sergeant Major — yellow top / grey-white bottom, 5 black bars
    SpriteSpec("sergeant_major", "Sergeant Major", "fish", "fish_sergeant",
               (220, 210, 50, 255), (200, 210, 210, 255), (20, 20, 25, 255)),
    # Parrotfish — teal-green, orange face marks, grey beak, lunate tail
    SpriteSpec("parrotfish", "Parrotfish", "fish", "fish_parrot",
               (50, 180, 140, 255), (220, 110, 40, 255), (100, 150, 120, 255)),
]


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def clamp(v: int, lo: int, hi: int) -> int:
    return max(lo, min(hi, v))


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def s(v: float, w: int) -> int:
    """Scale a 128px-base value to the current sprite width."""
    return int(v * (w / 128.0))


def blend_color(c1: Color, c2: Color, t: float) -> Color:
    return (
        int(lerp(c1[0], c2[0], t)),
        int(lerp(c1[1], c2[1], t)),
        int(lerp(c1[2], c2[2], t)),
        255,
    )


def draw_thick_line(draw: ImageDraw.ImageDraw, pts: List[Tuple[int, int]], color: Color, width: int) -> None:
    """Draw a polyline with specified pixel width."""
    if len(pts) < 2:
        return
    for i in range(len(pts) - 1):
        x0, y0 = pts[i]
        x1, y1 = pts[i + 1]
        draw.line((x0, y0, x1, y1), fill=color, width=width)


def draw_egg(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int) -> None:
    """Generic egg — glowing oval with embryo, bobbing and pulsing."""
    # Bobbing
    y_off = int(math.sin(frame * 0.5) * s(4, w))
    # Pulsing
    pulse = 1.0 + math.sin(frame * 0.4) * 0.1
    
    cx = w // 2
    cy = h // 2 + y_off
    
    rx = int(s(24, w) * pulse)
    ry = int(s(32, w) * pulse)
    
    # Outer glow
    for i in range(4):
        glow_r = int(rx * (1.1 + i * 0.15))
        glow_h = int(ry * (1.1 + i * 0.15))
        alpha = int(80 / (i + 1))
        color = (*spec.primary[:3], alpha)
        draw.ellipse((cx - glow_r, cy - glow_h, cx + glow_r, cy + glow_h), fill=color)

    # Egg body
    draw.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=spec.primary)
    
    # Inner highlights
    highlight = (*spec.secondary[:3], 180)
    draw.ellipse((cx - int(rx * 0.6), cy - int(ry * 0.7), cx + int(rx * 0.2), cy - int(ry * 0.3)), fill=highlight)

    # Embryo curl (dark silhouette)
    embryo_pts = []
    for i in range(12):
        t = i / 11.0
        angle = t * math.pi * 1.5
        er = rx * 0.4 * (1.0 - t * 0.3)
        ex = cx + math.cos(angle) * er
        ey = cy + math.sin(angle) * er
        embryo_pts.append((int(ex), int(ey)))
    
    draw_thick_line(draw, embryo_pts, (20, 20, 30, 150), width=s(3, w))


# ---------------------------------------------------------------------------
# Coral drawing functions
# ---------------------------------------------------------------------------

def draw_black_coral_fan(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Antipathes atlantica — nearly black mesh-like fan rising from base."""
    sway = math.sin(frame * 0.3) * 0.015
    cx = w // 2
    base_y = int(h * 0.88)

    # Main stem
    stem_top_x = cx + int(sway * w)
    stem_top_y = int(h * 0.18)
    draw.line((cx, base_y, stem_top_x, stem_top_y), fill=spec.primary, width=s(4 if not is_card else 6, w))

    # Fan branches spreading from stem
    num_branches = 12 if not is_card else 6
    for i in range(num_branches):
        t = (i + 1) / (num_branches + 1)
        stem_x = int(lerp(cx, stem_top_x, t))
        stem_y = int(lerp(base_y, stem_top_y, t))
        spread = (1.0 - t) * w * 0.36 + t * w * 0.08
        angle_sway = math.sin(frame * 0.4 + i * 0.5) * s(3, w)

        for side in (-1, 1):
            end_x = int(stem_x + side * spread + angle_sway)
            end_y = int(stem_y - int(h * 0.04 * (1 - t)))
            draw.line((stem_x, stem_y, end_x, end_y), fill=spec.primary, width=s(2 if not is_card else 3, w))
            
            if not is_card:
                # Sub-branches
                mid_x = (stem_x + end_x) // 2
                mid_y = (stem_y + end_y) // 2
                sub_end_x = int(mid_x + side * spread * 0.3)
                sub_end_y = int(mid_y - int(h * 0.05))
                draw.line((mid_x, mid_y, sub_end_x, sub_end_y), fill=spec.secondary, width=s(1, w))

    # Connecting horizontal mesh lines
    if not is_card:
        for step in range(3, 9):
            t = step / 10.0
            y = int(lerp(base_y, stem_top_y + int(h * 0.05), t))
            fan_w = int(w * 0.36 * (1.0 - t * 0.6))
            x_left = cx - fan_w
            x_right = cx + fan_w
            draw.line((x_left, y, x_right, y), fill=spec.secondary, width=s(1, w))


def draw_forked_coral(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Antipathes furcata — dark Y-branching whip coral."""
    sway_amp = math.sin(frame * 0.35) * w * 0.02
    cx = w // 2
    base_y = int(h * 0.9)

    def branch(x0: int, y0: int, x1: int, y1: int, depth: int) -> None:
        if depth == 0 or abs(y1 - y0) < s(4, w):
            return
        sw = int(sway_amp * (depth / 4.0))
        x1a = x1 + sw
        draw.line((x0, y0, x1a, y1), fill=spec.primary, width=max(s(1, w), s(depth if not is_card else depth + 1, w)))
        length = math.hypot(x1a - x0, y1 - y0)
        dx = (x1a - x0) / length
        dy = (y1 - y0) / length
        fork_len = int(length * 0.6)
        angle = 0.42
        lx = int(x1a + (dx * math.cos(angle) - dy * math.sin(angle)) * fork_len)
        ly = int(y1 + (dx * math.sin(angle) + dy * math.cos(angle)) * fork_len)
        rx = int(x1a + (dx * math.cos(-angle) - dy * math.sin(-angle)) * fork_len)
        ry = int(y1 + (dx * math.sin(-angle) + dy * math.cos(-angle)) * fork_len)
        branch(x1a, y1, lx, ly, depth - 1)
        branch(x1a, y1, rx, ry, depth - 1)

    branch(cx, base_y, cx, int(h * 0.55), 5 if not is_card else 3)

    # Polyp dots along branches
    if not is_card:
        for y in range(int(h * 0.1), int(h * 0.85), int(h * 0.07)):
            x = cx + int(math.sin(y * 0.3 + frame * 0.4) * w * 0.12)
            draw.ellipse((x - s(1, w), y - s(1, w), x + s(1, w), y + s(1, w)), fill=spec.tertiary)


def draw_golden_bush(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Bebryce Sp. — golden-yellow multi-branching bush."""
    sway = math.sin(frame * 0.4) * w * 0.02
    cx = w // 2
    base_y = int(h * 0.88)

    def golden_branch(x0: int, y0: int, angle_deg: float, length: int, depth: int) -> None:
        if depth == 0 or length < s(3, w):
            return
        rad = math.radians(angle_deg)
        sw = sway * (depth / 5.0) * math.sin(frame * 0.5 + depth)
        x1 = int(x0 + math.cos(rad) * length + sw)
        y1 = int(y0 - abs(math.sin(rad)) * length)
        thick = max(s(1, w), s(depth if not is_card else depth + 1, w))
        color = blend_color(spec.primary, spec.secondary, 1.0 - depth / 5.0)
        draw.line((x0, y0, x1, y1), fill=color, width=thick)
        # Polyp tips
        if depth == 1 and not is_card:
            draw.ellipse((x1 - s(2, w), y1 - s(2, w), x1 + s(2, w), y1 + s(2, w)), fill=spec.tertiary)
        spread = 22
        golden_branch(x1, y1, angle_deg - spread, int(length * 0.72), depth - 1)
        golden_branch(x1, y1, angle_deg + spread, int(length * 0.72), depth - 1)
        if depth >= (3 if not is_card else 4):
            golden_branch(x1, y1, angle_deg, int(length * 0.60), depth - 1)

    main_len = int(h * 0.28)
    golden_branch(cx - int(w * 0.12), base_y, 75, main_len, 5 if not is_card else 4)
    golden_branch(cx, base_y, 90, int(main_len * 1.1), 5 if not is_card else 4)
    golden_branch(cx + int(w * 0.12), base_y, 105, main_len, 5 if not is_card else 4)


def draw_sea_whip(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Ellisellidae — tall vivid orange-red whip with white polyp dots."""
    cx = w // 2
    base_y = int(h * 0.9)
    top_y = int(h * 0.06)

    pts: List[Tuple[int, int]] = []
    steps = 32 if not is_card else 16
    for i in range(steps + 1):
        t = i / steps
        y = int(lerp(base_y, top_y, t))
        amplitude = w * (0.04 + t * 0.06)
        x = int(cx + math.sin(t * 3.0 * math.pi + frame * 0.45) * amplitude)
        pts.append((x, y))

    # Main whip stem — thick at base, tapers
    for i in range(len(pts) - 1):
        t = i / (len(pts) - 1)
        thickness = max(s(3, w), s(9 - t * 6, w))
        if is_card: thickness += s(2, w)
        draw.line((pts[i][0], pts[i][1], pts[i+1][0], pts[i+1][1]), fill=spec.primary, width=thickness)

    # White polyp tufts on alternating sides — larger and more visible
    polyp_step = 2 if not is_card else 4
    for i in range(1, len(pts), polyp_step):
        x, y = pts[i]
        side = 1 if (i % (polyp_step * 2) == 0) else -1
        t = i / len(pts)
        polyp_len = s(8 - t * 4, w)
        if is_card: polyp_len += s(2, w)
        px_tip = x + side * polyp_len
        draw.line((x, y, px_tip, y), fill=spec.tertiary, width=s(2 if not is_card else 3, w))
        draw.ellipse((px_tip - s(3, w), y - s(3, w), px_tip + s(3, w), y + s(3, w)), fill=spec.tertiary)


def draw_pencil_coral(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Madracis Sp. — bright yellow finger-like pencil branches."""
    cx = w // 2
    base_y = int(h * 0.9)
    sway = math.sin(frame * 0.4) * w * 0.015

    offsets = [-0.28, -0.16, -0.05, 0.07, 0.18, 0.29] if not is_card else [-0.22, 0.0, 0.22]
    heights = [0.42, 0.28, 0.22, 0.25, 0.30, 0.40] if not is_card else [0.38, 0.25, 0.35]

    for i, (off, ht) in enumerate(zip(offsets, heights)):
        x_bot = int(cx + off * w)
        x_top = int(x_bot + sway * (1 - ht))
        y_top = int(h * ht)
        finger_w = s(7 if not is_card else 10, w)
        # Finger body
        draw.rounded_rectangle(
            (x_bot - finger_w, y_top, x_bot + finger_w, base_y),
            radius=int(finger_w * 0.8),
            fill=spec.primary
        )
        # Rounded tip
        tip_r = finger_w + s(1, w)
        draw.ellipse(
            (x_top - tip_r, y_top - tip_r, x_top + tip_r, y_top + tip_r),
            fill=spec.secondary
        )
        # Subtle ridge line
        if not is_card:
            draw.line((x_bot, y_top + int(h * 0.03), x_bot, base_y - 4), fill=spec.tertiary, width=s(1, w))

    # Base rock
    draw.ellipse((cx - int(w * 0.3), base_y - int(h * 0.06), cx + int(w * 0.3), base_y + int(h * 0.04)),
                 fill=spec.tertiary)


def draw_zigzag_coral(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Madrepora Sp. — pale pink fine zigzag branching with bump polyps."""
    sway = math.sin(frame * 0.35) * w * 0.018
    cx = w // 2
    base_y = int(h * 0.9)

    def zz_branch(x0: int, y0: int, dx: float, dy: float, length: int, depth: int) -> None:
        if depth == 0 or length < s(4, w):
            return
        sw = sway * (depth / 4.0)
        x1 = int(x0 + dx * length + sw)
        y1 = int(y0 + dy * length)
        color = blend_color(spec.primary, spec.secondary, 1.0 - depth / 4.0)
        thick = max(s(1, w), s(depth - 1 if not is_card else depth, w))
        draw.line((x0, y0, x1, y1), fill=color, width=thick)
        # Polyp bumps along branch
        if not is_card:
            steps_b = max(2, length // 6)
            for s_idx in range(1, steps_b):
                t = s_idx / steps_b
                px = int(lerp(x0, x1, t))
                py = int(lerp(y0, y1, t))
                r = s(2, w) if depth >= 3 else s(1, w)
                draw.ellipse((px - r, py - r, px + r, py + r), fill=spec.secondary)
        # Fork
        new_len = int(length * 0.68)
        fork_angle = 0.4
        for side in (-1, 1):
            ndx = dx * math.cos(fork_angle * side) - dy * math.sin(fork_angle * side)
            ndy = dx * math.sin(fork_angle * side) + dy * math.cos(fork_angle * side)
            zz_branch(x1, y1, ndx, ndy, new_len, depth - 1)

    if not is_card:
        zz_branch(cx - int(w * 0.08), base_y, -0.1, -1.0, int(h * 0.22), 4)
        zz_branch(cx + int(w * 0.04), base_y, 0.08, -1.0, int(h * 0.28), 4)
        zz_branch(cx + int(w * 0.18), base_y, 0.2, -1.0, int(h * 0.20), 3)
    else:
        zz_branch(cx, base_y, 0.0, -1.0, int(h * 0.35), 3)


def draw_pinnate_fan(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Muricea pendula — amber-yellow feather/pinnate fan."""
    sway = math.sin(frame * 0.35) * w * 0.025
    cx = w // 2
    base_y = int(h * 0.9)
    top_y = int(h * 0.1)

    # Central rachis (spine)
    spine_x_top = cx + int(sway)
    draw.line((cx, base_y, spine_x_top, top_y), fill=spec.primary, width=s(4 if not is_card else 6, w))

    # Pinnules (feather barbs) along spine
    num_pinnules = 20 if not is_card else 10
    for i in range(num_pinnules):
        t = i / (num_pinnules - 1)
        spine_x = int(lerp(cx, spine_x_top, t))
        spine_y = int(lerp(base_y, top_y, t))
        pinnule_len = int(w * (0.22 - t * 0.14))
        angle_sway = sway * 0.3

        for side, sign in ((-1, -1), (1, 1)):
            angle_deg = 70 + sign * 5
            rad = math.radians(angle_deg * side)
            end_x = int(spine_x + math.cos(rad) * pinnule_len + angle_sway)
            end_y = int(spine_y - abs(math.sin(rad)) * pinnule_len * 0.5)
            color = blend_color(spec.primary, spec.secondary, t)
            draw.line((spine_x, spine_y, end_x, end_y), fill=color, width=s(2 if not is_card else 4, w))
            # Small polyp bumps
            if not is_card:
                for s_val in (0.4, 0.7, 1.0):
                    px = int(lerp(spine_x, end_x, s_val))
                    py = int(lerp(spine_y, end_y, s_val))
                    draw.ellipse((px - s(1, w), py - s(1, w), px + s(1, w), py + s(1, w)), fill=spec.tertiary)


def draw_spiky_gorgonian(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Acanthogorgiidae — orange branches with dark visible axis and spiky polyps."""
    sway = math.sin(frame * 0.4) * w * 0.02
    cx = w // 2
    base_y = int(h * 0.9)

    def spiky_branch(x0: int, y0: int, angle_deg: float, length: int, depth: int) -> None:
        if depth == 0 or length < s(4, w):
            return
        rad = math.radians(angle_deg)
        sw = sway * (depth / 5.0)
        x1 = int(x0 + math.cos(rad) * length + sw)
        y1 = int(y0 - abs(math.sin(rad)) * length)
        # Orange flesh
        draw.line((x0, y0, x1, y1), fill=spec.primary, width=max(s(2, w), s(depth if not is_card else depth + 1, w)))
        # Dark axis visible through
        if not is_card:
            draw.line((x0, y0, x1, y1), fill=spec.secondary, width=s(1, w))
        # Spiky polyps
        if not is_card:
            steps_b = max(3, length // 5)
            for s_idx in range(1, steps_b):
                t_s = s_idx / steps_b
                px = int(lerp(x0, x1, t_s))
                py = int(lerp(y0, y1, t_s))
                for spike_angle in range(0, 360, 45):
                    sa_rad = math.radians(spike_angle + frame * 5)
                    sx = int(px + math.cos(sa_rad) * 3)
                    sy = int(py + math.sin(sa_rad) * 3)
                    draw.line((px, py, sx, sy), fill=spec.tertiary, width=s(1, w))
        elif depth <= 2:
             # Just a few big spikes for card
             draw.ellipse((x1 - s(3, w), y1 - s(3, w), x1 + s(3, w), y1 + s(3, w)), fill=spec.tertiary)
             
        spread = 30
        spiky_branch(x1, y1, angle_deg - spread, int(length * 0.65), depth - 1)
        spiky_branch(x1, y1, angle_deg + spread, int(length * 0.65), depth - 1)

    spiky_branch(cx - int(w * 0.06), base_y, 85, int(h * 0.30), 4 if not is_card else 3)
    spiky_branch(cx + int(w * 0.06), base_y, 95, int(h * 0.28), 4 if not is_card else 3)


def draw_wire_coral(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Stichopathes — single thin spiralling wire, one-sided white polyps."""
    cx = w // 2
    base_y = int(h * 0.92)
    top_y = int(h * 0.05)

    steps = 48 if not is_card else 24
    pts: List[Tuple[int, int]] = []
    for i in range(steps + 1):
        t = i / steps
        y = int(lerp(base_y, top_y, t))
        spiral_amp = w * (0.15 * (1.0 - t * 0.5))
        x = int(cx + math.sin(t * 4.0 * math.pi + frame * 0.5) * spiral_amp)
        pts.append((x, y))

    # Single dark wire
    for i in range(len(pts) - 1):
        draw.line((pts[i][0], pts[i][1], pts[i+1][0], pts[i+1][1]), fill=spec.primary, width=s(2 if not is_card else 5, w))

    # One-sided white polyps
    polyp_step = 2 if not is_card else 6
    for i in range(1, len(pts) - 1, polyp_step):
        x, y = pts[i]
        prev_x, prev_y = pts[i - 1]
        dx = x - prev_x
        dy = y - prev_y
        length = max(1, math.hypot(dx, dy))
        perp_x = -dy / length
        perp_y = dx / length
        px = int(x + perp_x * s(5, w))
        py = int(y + perp_y * s(5, w))
        draw.ellipse((px - s(1 if not is_card else 3, w), py - s(1 if not is_card else 3, w), 
                      px + s(1 if not is_card else 3, w), py + s(1 if not is_card else 3, w)), 
                     fill=spec.tertiary)


def draw_orange_tree(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Swiftia exserta — vivid orange branching tree with red polyp dots."""
    sway = math.sin(frame * 0.38) * w * 0.022
    cx = w // 2
    base_y = int(h * 0.9)

    def orange_branch(x0: int, y0: int, angle_deg: float, length: int, depth: int) -> None:
        if depth == 0 or length < s(5, w):
            return
        rad = math.radians(angle_deg)
        sw = sway * (1.0 - depth / 5.0)
        x1 = int(x0 + math.cos(rad) * length + sw)
        y1 = int(y0 - abs(math.sin(rad)) * length)
        thick = max(s(2, w), s(depth if not is_card else depth + 1, w))
        draw.line((x0, y0, x1, y1), fill=spec.primary, width=thick)
        # Red polyp dots
        if depth == 1:
            draw.ellipse((x1 - s(3, w), y1 - s(3, w), x1 + s(3, w), y1 + s(3, w)), fill=spec.secondary)
        elif not is_card:
            mid_x = (x0 + x1) // 2
            mid_y = (y0 + y1) // 2
            draw.ellipse((mid_x - s(2, w), mid_y - s(2, w), mid_x + s(2, w), mid_y + s(2, w)), fill=spec.secondary)
        spread = 28 + depth * 2
        orange_branch(x1, y1, angle_deg - spread, int(length * 0.68), depth - 1)
        orange_branch(x1, y1, angle_deg + spread, int(length * 0.68), depth - 1)
        if depth >= (3 if not is_card else 4):
            orange_branch(x1, y1, angle_deg, int(length * 0.55), depth - 2)

    orange_branch(cx, base_y, 90, int(h * 0.32), 5 if not is_card else 4)


def draw_white_eye_fan(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Thesea nivea — red-purple flat fan with distinctive white eye polyps."""
    sway = math.sin(frame * 0.3) * w * 0.02
    cx = w // 2
    base_y = int(h * 0.88)
    top_y = int(h * 0.1)

    # Wide flat fan structure
    stem_x_top = cx + int(sway)
    draw.line((cx, base_y, stem_x_top, top_y), fill=spec.primary, width=s(5 if not is_card else 8, w))

    # Fan ribs spreading from base to top
    num_ribs = 14 if not is_card else 6
    for i in range(num_ribs):
        t = (i + 0.5) / num_ribs
        rib_start_y = int(lerp(base_y, top_y, 0.05))
        rib_start_x = int(lerp(cx - int(w * 0.05), cx + int(w * 0.05), t))
        spread_x = int(lerp(-w * 0.38, w * 0.38, t))
        top_x = cx + int(spread_x * 0.85) + int(sway * 0.5)
        draw.line((rib_start_x, rib_start_y, top_x, top_y + int(h * 0.04)), fill=spec.primary, width=s(2 if not is_card else 4, w))

    # Horizontal connecting bars
    if not is_card:
        for step in range(2, 9):
            t = step / 10.0
            y = int(lerp(base_y, top_y + int(h * 0.06), t))
            fan_w = int(w * 0.40 * (1.0 - t * 0.5) + w * 0.04)
            x_left = cx - fan_w
            x_right = cx + fan_w
            draw.line((x_left, y, x_right, y), fill=spec.secondary, width=s(1, w))

    # White eye polyps
    polyp_r = s(3 if not is_card else 5, w)
    rows = range(3, 9) if not is_card else [4, 7]
    for row in rows:
        ty = row / 10.0
        y = int(lerp(base_y, top_y + int(h * 0.08), ty))
        row_fan_w = int(w * 0.38 * (1.0 - ty * 0.45))
        num_polyps = max(2, int(row_fan_w / (s(12, w) if not is_card else s(20, w))))
        for p in range(num_polyps):
            px = cx - row_fan_w + int(row_fan_w * 2 * (p + 0.5) / num_polyps)
            px += int(sway * 0.3)
            draw.ellipse((px - polyp_r, y - polyp_r, px + polyp_r, y + polyp_r), fill=spec.tertiary)
            if not is_card:
                draw.ellipse((px - s(1, w), y - s(1, w), px + s(1, w), y + s(1, w)), fill=(100, 30, 50, 255))


def draw_barrel_sponge(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Barrel sponge — reddish-brown barrel with open top and vertical ridges."""
    wobble = int(math.sin(frame * 0.5) * w * 0.008)
    cx = w // 2 + wobble
    barrel_left = int(w * 0.2)
    barrel_right = int(w * 0.8)
    barrel_top = int(h * 0.22)
    barrel_bot = int(h * 0.88)
    barrel_w = barrel_right - barrel_left
    barrel_h = barrel_bot - barrel_top

    # Main barrel body
    draw.rounded_rectangle(
        (barrel_left + wobble, barrel_top, barrel_right + wobble, barrel_bot),
        radius=int(barrel_w * 0.18),
        fill=spec.primary
    )

    # Vertical ridges
    num_ridges = 8 if not is_card else 4
    for i in range(1, num_ridges):
        rx = barrel_left + wobble + int(barrel_w * i / num_ridges)
        draw.line((rx, barrel_top + int(barrel_h * 0.08), rx, barrel_bot - int(barrel_h * 0.04)),
                  fill=spec.secondary, width=s(2 if not is_card else 4, w))

    # Inner cavity
    inner_w = int(barrel_w * 0.52)
    inner_h = int(barrel_h * 0.14)
    inner_cx = cx
    draw.ellipse(
        (inner_cx - inner_w // 2, barrel_top - inner_h // 2,
         inner_cx + inner_w // 2, barrel_top + inner_h),
        fill=spec.tertiary
    )
    # Top rim highlight
    draw.arc(
        (inner_cx - inner_w // 2 - s(2, w), barrel_top - inner_h // 2 - s(4, w),
         inner_cx + inner_w // 2 + s(2, w), barrel_top + inner_h - s(2, w)),
        start=200, end=340, fill=spec.secondary, width=s(3 if not is_card else 5, w)
    )

    # Textured surface bumps
    if not is_card:
        for bx in range(int(barrel_left + barrel_w * 0.12), int(barrel_right - barrel_w * 0.08), int(barrel_w * 0.11)):
            for by_off in range(int(barrel_h * 0.18), int(barrel_h * 0.85), int(barrel_h * 0.12)):
                bx_w = bx + wobble
                by = barrel_top + by_off
                draw.ellipse((bx_w - s(2, w), by - s(2, w), bx_w + s(3, w), by + s(3, w)), fill=spec.secondary)


# ---------------------------------------------------------------------------
# Fish drawing functions
# ---------------------------------------------------------------------------

def draw_chromis(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Blue Chromis — electric blue oval, black dorsal stripe, forked tail."""
    swim = int(math.sin(frame * 0.65) * w * 0.022)
    tail_wag = math.sin(frame * 0.65) * 0.12
    cx = w // 2 + swim
    cy = h // 2

    body_rx = int(w * 0.27)
    body_ry = int(h * 0.15)

    # Forked tail
    tail_cx = cx - body_rx - int(w * 0.03)
    fork_spread = int(h * 0.13)
    tail_tip_x = cx - body_rx - int(w * 0.16)
    wag_off = int(tail_wag * h * 0.08)
    for sign in (-1, 1):
        tip_y = cy + sign * fork_spread + wag_off
        fork_pts = [
            (tail_cx, cy + wag_off),
            (tail_cx - int(w * 0.04), cy + sign * fork_spread * 0.4 + wag_off),
            (tail_tip_x, tip_y),
        ]
        draw.polygon(fork_pts, fill=spec.secondary)

    # Body
    draw.ellipse((cx - body_rx, cy - body_ry, cx + body_rx, cy + body_ry), fill=spec.primary)

    # Black dorsal stripe
    stripe_w = s(4 if not is_card else 7, w)
    stripe_pts = [
        (cx - int(body_rx * 0.7), cy - body_ry + 1),
        (cx + int(body_rx * 0.7), cy - body_ry + 1),
        (cx + int(body_rx * 0.5), cy - body_ry + stripe_w),
        (cx - int(body_rx * 0.5), cy - body_ry + stripe_w),
    ]
    draw.polygon(stripe_pts, fill=(10, 10, 20, 255))

    # Dorsal fin
    dorsal_h = s(12 if not is_card else 18, w)
    dorsal = [
        (cx - int(body_rx * 0.2), cy - body_ry),
        (cx + int(body_rx * 0.35), cy - body_ry - dorsal_h),
        (cx + int(body_rx * 0.55), cy - body_ry),
    ]
    draw.polygon(dorsal, fill=spec.secondary)

    # Eye
    eye_x = cx + int(body_rx * 0.55)
    eye_y = cy - int(body_ry * 0.2)
    eye_r = s(3 if not is_card else 5, w)
    draw.ellipse((eye_x - eye_r, eye_y - eye_r, eye_x + eye_r, eye_y + eye_r), fill=(255, 255, 255, 255))
    draw.ellipse((eye_x - s(1 if not is_card else 2, w), eye_y - s(1 if not is_card else 2, w), 
                  eye_x + s(1 if not is_card else 2, w), eye_y + s(1 if not is_card else 2, w)), 
                 fill=(10, 10, 10, 255))


def draw_angelfish(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """French Angelfish — black disc, golden scale dots, orange pectoral bar, tall fins."""
    swim = int(math.sin(frame * 0.5) * w * 0.018)
    cx = w // 2 + swim
    cy = h // 2

    body_rx = int(w * 0.26)
    body_ry = int(h * 0.24)

    # Rounded tail
    tail_pts = [
        (cx - body_rx, cy - int(body_ry * 0.3)),
        (cx - body_rx - int(w * 0.12), cy - int(h * 0.18)),
        (cx - body_rx - int(w * 0.12), cy + int(h * 0.18)),
        (cx - body_rx, cy + int(body_ry * 0.3)),
    ]
    draw.polygon(tail_pts, fill=spec.primary)

    # Body disc
    draw.ellipse((cx - body_rx, cy - body_ry, cx + body_rx, cy + body_ry), fill=spec.primary)

    # Tall dorsal fin
    dorsal_h = s(22 if not is_card else 28, w)
    dorsal = [
        (cx - int(body_rx * 0.4), cy - body_ry),
        (cx, cy - body_ry - dorsal_h),
        (cx + int(body_rx * 0.55), cy - body_ry - s(8, w)),
        (cx + int(body_rx * 0.6), cy - body_ry),
    ]
    draw.polygon(dorsal, fill=spec.primary)

    # Tall anal fin
    anal_h = s(20 if not is_card else 26, w)
    anal = [
        (cx - int(body_rx * 0.3), cy + body_ry),
        (cx + int(body_rx * 0.1), cy + body_ry + anal_h),
        (cx + int(body_rx * 0.5), cy + body_ry),
    ]
    draw.polygon(anal, fill=spec.primary)

    # Orange pectoral bar stripe
    bar_pts = [
        (cx - int(body_rx * 0.3), cy - int(body_ry * 0.6)),
        (cx + int(body_rx * 0.05), cy - int(body_ry * 0.6)),
        (cx + int(body_rx * 0.05), cy + int(body_ry * 0.6)),
        (cx - int(body_rx * 0.3), cy + int(body_ry * 0.6)),
    ]
    draw.polygon(bar_pts, fill=spec.tertiary)

    # Golden scale-edge dots
    if not is_card:
        import random
        rng = random.Random(42)
        for _ in range(28):
            dx = rng.uniform(-0.75, 0.75)
            dy = rng.uniform(-0.85, 0.85)
            if (dx ** 2 + dy ** 2) < 0.70:
                px = int(cx + dx * body_rx)
                py = int(cy + dy * body_ry)
                draw.point((px, py), fill=spec.secondary)
                draw.point((px + 1, py), fill=spec.secondary)
    else:
        # Just a few big golden spots for card
        for dx, dy in [(-0.3, -0.3), (0.2, 0.1), (-0.1, 0.4)]:
            px = int(cx + dx * body_rx)
            py = int(cy + dy * body_ry)
            r = s(3, w)
            draw.ellipse((px - r, py - r, px + r, py + r), fill=spec.secondary)

    # Eye
    eye_x = cx + int(body_rx * 0.62)
    eye_y = cy - int(body_ry * 0.2)
    eye_r = s(4 if not is_card else 6, w)
    draw.ellipse((eye_x - eye_r, eye_y - eye_r, eye_x + eye_r, eye_y + eye_r), fill=(255, 255, 255, 255))
    draw.ellipse((eye_x - s(2, w), eye_y - s(2, w), eye_x + s(2, w), eye_y + s(2, w)), fill=(10, 10, 10, 255))


def draw_wrasse(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Creole Wrasse — purple elongate body, dark snout, deep-V tail."""
    swim = int(math.sin(frame * 0.7) * w * 0.022)
    cx = w // 2 + swim
    cy = h // 2

    body_rx = int(w * 0.34)
    body_ry = int(h * 0.12)

    # Deep V-tail (lunate)
    tail_cx = cx - body_rx
    v_spread = int(h * 0.16)
    tail_pts = [
        (tail_cx, cy),
        (tail_cx - int(w * 0.05), cy - v_spread),
        (tail_cx - int(w * 0.14), cy - v_spread - int(h * 0.04)),
        (tail_cx - int(w * 0.12), cy),
        (tail_cx - int(w * 0.14), cy + v_spread + int(h * 0.04)),
        (tail_cx - int(w * 0.05), cy + v_spread),
    ]
    draw.polygon(tail_pts, fill=spec.primary)

    # Body
    draw.ellipse((cx - body_rx, cy - body_ry, cx + body_rx, cy + body_ry), fill=spec.primary)

    # Dark snout tip
    snout_x = cx + int(body_rx * 0.72)
    draw.ellipse((snout_x, cy - int(body_ry * 0.55), cx + body_rx + int(w * 0.03), cy + int(body_ry * 0.55)), fill=spec.secondary)

    # Lighter purple highlight
    if not is_card:
        draw.arc(
            (cx - body_rx + int(w * 0.05), cy - body_ry + 2,
             cx + body_rx - int(w * 0.1), cy),
            start=200, end=340, fill=spec.tertiary, width=s(3, w)
        )

    # Eye
    eye_x = cx + int(body_rx * 0.65)
    eye_y = cy - int(body_ry * 0.1)
    eye_r = s(3 if not is_card else 5, w)
    draw.ellipse((eye_x - eye_r, eye_y - eye_r, eye_x + eye_r, eye_y + eye_r), fill=(255, 255, 255, 255))
    draw.ellipse((eye_x - s(1 if not is_card else 2, w), eye_y - s(1 if not is_card else 2, w), 
                  eye_x + s(1 if not is_card else 2, w), eye_y + s(1 if not is_card else 2, w)), 
                 fill=(10, 10, 10, 255))


def draw_sergeant(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Sergeant Major — squat oval, yellow top / grey bottom, 5 black bars."""
    swim = int(math.sin(frame * 0.6) * w * 0.02)
    cx = w // 2 + swim
    cy = h // 2

    body_rx = int(w * 0.28)
    body_ry = int(h * 0.19)

    # Tail
    tail_pts = [
        (cx - body_rx, cy - int(body_ry * 0.4)),
        (cx - body_rx - int(w * 0.12), cy - int(h * 0.16)),
        (cx - body_rx - int(w * 0.12), cy + int(h * 0.16)),
        (cx - body_rx, cy + int(body_ry * 0.4)),
    ]
    draw.polygon(tail_pts, fill=spec.primary)

    # Body — yellow upper half
    draw.ellipse((cx - body_rx, cy - body_ry, cx + body_rx, cy + body_ry), fill=spec.primary)

    # Grey-white lower half
    draw.chord(
        (cx - body_rx, cy, cx + body_rx, cy + body_ry + int(h * 0.04)),
        start=0, end=180, fill=spec.secondary
    )

    # 5 vertical black bars
    num_bars = 5 if not is_card else 3
    bar_spacing = body_rx * 2 / (num_bars + 1)
    for i in range(num_bars):
        bx = int(cx - body_rx + bar_spacing * (i + 0.7))
        bar_top = cy - body_ry + int(body_ry * 0.15)
        bar_bot = cy + body_ry - int(body_ry * 0.15)
        draw.line((bx, bar_top, bx, bar_bot), fill=spec.tertiary, width=int(bar_spacing * (0.45 if not is_card else 0.6)))

    # Dorsal fin
    dorsal_h = s(10 if not is_card else 15, w)
    dorsal = [
        (cx - int(body_rx * 0.5), cy - body_ry),
        (cx, cy - body_ry - dorsal_h),
        (cx + int(body_rx * 0.4), cy - body_ry),
    ]
    draw.polygon(dorsal, fill=spec.primary)

    # Eye
    eye_x = cx + int(body_rx * 0.6)
    eye_y = cy - int(body_ry * 0.25)
    eye_r = s(3 if not is_card else 5, w)
    draw.ellipse((eye_x - eye_r, eye_y - eye_r, eye_x + eye_r, eye_y + eye_r), fill=(255, 255, 255, 255))
    draw.ellipse((eye_x - s(1 if not is_card else 2, w), eye_y - s(1 if not is_card else 2, w), 
                  eye_x + s(1 if not is_card else 2, w), eye_y + s(1 if not is_card else 2, w)), 
                 fill=(10, 10, 10, 255))


def draw_parrotfish(draw: ImageDraw.ImageDraw, w: int, h: int, spec: SpriteSpec, frame: int, is_card: bool = False) -> None:
    """Parrotfish — teal-green, orange face marks, grey beak, lunate tail."""
    swim = int(math.sin(frame * 0.6) * w * 0.02)
    cx = w // 2 + swim
    cy = h // 2

    body_rx = int(w * 0.32)
    body_ry = int(h * 0.17)

    # Lunate (crescent) tail
    tail_base = cx - body_rx
    lune_pts = [
        (tail_base, cy - int(body_ry * 0.5)),
        (tail_base - int(w * 0.14), cy - int(h * 0.20)),
        (tail_base - int(w * 0.16), cy - int(h * 0.14)),
        (tail_base - int(w * 0.06), cy),
        (tail_base - int(w * 0.16), cy + int(h * 0.14)),
        (tail_base - int(w * 0.14), cy + int(h * 0.20)),
        (tail_base, cy + int(body_ry * 0.5)),
    ]
    draw.polygon(lune_pts, fill=spec.primary)

    # Body
    draw.ellipse((cx - body_rx, cy - body_ry, cx + body_rx, cy + body_ry), fill=spec.primary)

    # Orange diagonal face marks
    face_x = cx + int(body_rx * 0.3)
    face_marks = [
        ((face_x, cy - int(body_ry * 0.75)), (face_x + int(w * 0.1), cy - int(body_ry * 0.2))),
        ((face_x + int(w * 0.04), cy + int(body_ry * 0.1)), (face_x + int(w * 0.12), cy + int(body_ry * 0.65))),
    ] if not is_card else [((face_x, cy - int(body_ry * 0.5)), (face_x + int(w * 0.12), cy + int(body_ry * 0.5)))]
    
    for (ax, ay), (bx, by) in face_marks:
        draw.line((ax, ay, bx, by), fill=spec.secondary, width=s(3 if not is_card else 6, w))

    # Grey-green fused beak
    beak_pts = [
        (cx + body_rx - int(w * 0.04), cy - int(body_ry * 0.3)),
        (cx + body_rx + int(w * 0.10), cy - int(body_ry * 0.12)),
        (cx + body_rx + int(w * 0.10), cy + int(body_ry * 0.12)),
        (cx + body_rx - int(w * 0.04), cy + int(body_ry * 0.3)),
    ]
    draw.polygon(beak_pts, fill=spec.tertiary)
    
    # Beak ridge line
    if not is_card:
        draw.line(
            (cx + body_rx, cy, cx + body_rx + int(w * 0.09), cy),
            fill=(60, 80, 60, 255), width=s(2, w)
        )

    # Dorsal fin
    dorsal_h = s(11 if not is_card else 16, w)
    dorsal = [
        (cx - int(body_rx * 0.3), cy - body_ry),
        (cx + int(body_rx * 0.1), cy - body_ry - dorsal_h),
        (cx + int(body_rx * 0.45), cy - body_ry),
    ]
    draw.polygon(dorsal, fill=spec.primary)

    # Eye
    eye_x = cx + int(body_rx * 0.62)
    eye_y = cy - int(body_ry * 0.25)
    eye_r = s(3 if not is_card else 5, w)
    draw.ellipse((eye_x - eye_r, eye_y - eye_r, eye_x + eye_r, eye_y + eye_r), fill=(255, 255, 255, 255))
    draw.ellipse((eye_x - s(1 if not is_card else 2, w), eye_y - s(1 if not is_card else 2, w), 
                  eye_x + s(1 if not is_card else 2, w), eye_y + s(1 if not is_card else 2, w)), 
                 fill=(10, 10, 10, 255))


# ---------------------------------------------------------------------------
# Dispatcher
# ---------------------------------------------------------------------------

CORAL_DRAW_FNS = {
    "black_coral_fan": draw_black_coral_fan,
    "forked_coral": draw_forked_coral,
    "golden_bush": draw_golden_bush,
    "sea_whip": draw_sea_whip,
    "pencil_coral": draw_pencil_coral,
    "zigzag_coral": draw_zigzag_coral,
    "pinnate_fan": draw_pinnate_fan,
    "spiky_gorgonian": draw_spiky_gorgonian,
    "wire_coral": draw_wire_coral,
    "orange_tree": draw_orange_tree,
    "white_eye_fan": draw_white_eye_fan,
    "barrel_sponge": draw_barrel_sponge,
}

FISH_DRAW_FNS = {
    "fish_chromis": draw_chromis,
    "fish_angelfish": draw_angelfish,
    "fish_wrasse": draw_wrasse,
    "fish_sergeant": draw_sergeant,
    "fish_parrot": draw_parrotfish,
}


def draw_sprite(spec: SpriteSpec, width: int, height: int, frame: int, style: str = "standard") -> Image.Image:
    image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    if style == "egg":
        draw_egg(draw, width, height, spec, frame)
        return image

    is_card = (style == "card")
    if spec.category == "fish":
        fn = FISH_DRAW_FNS.get(spec.shape)
    else:
        fn = CORAL_DRAW_FNS.get(spec.shape)

    if fn is not None:
        # Check if fn accepts is_card
        import inspect
        sig = inspect.signature(fn)
        if "is_card" in sig.parameters:
            fn(draw, width, height, spec, frame, is_card=is_card)
        else:
            fn(draw, width, height, spec, frame)
    else:
        # Fallback: solid coloured square with label
        draw.rectangle((s(4, width), s(4, width), width - s(4, width), height - s(4, width)), fill=spec.primary)

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
                "card_sheet": f"sheets/{s.slug}_card_sheet.png",
                "egg_sheet": f"sheets/{s.slug}_egg_sheet.png",
            }
            for s in specs
        ],
    }
    # Ensure meta dir exists
    ensure_dir(os.path.join(out_dir, "meta"))
    with open(os.path.join(out_dir, "meta", "species_index.json"), "w", encoding="utf-8") as fp:
        json.dump(index, fp, indent=2)


def write_tres(out_dir: str, prefix: str, slug: str, frames_count: int) -> None:
    """Generate a Godot .tres (SpriteFrames) file."""
    lines = [
        '[gd_resource type="SpriteFrames" load_steps=%d format=3]' % (frames_count + 1),
        ''
    ]
    
    # ext_resource lines
    for i in range(frames_count):
        lines.append('[ext_resource type="Texture2D" path="res://assets/sprites/%s_frame_%02d.png" id="%d"]' % (prefix, i, i + 1))
    
    lines.append('')
    lines.append('[resource]')
    lines.append('animations = [{"frames": [')
    
    frame_entries = []
    for i in range(frames_count):
        frame_entries.append('{"duration": 1.0, "texture": ExtResource("%d")}' % (i + 1))
    
    lines.append(', '.join(frame_entries))
    lines.append('],')
    lines.append('"loop": true,')
    lines.append('"name": &"default",')
    lines.append('"speed": 5.0')
    lines.append('}]')
    
    tres_path = os.path.join(out_dir, f"{prefix}.tres")
    with open(tres_path, "w", encoding="utf-8") as fp:
        fp.write('\n'.join(lines) + '\n')


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate 248x248 pixel art sprites for all Coral Clicker species.")
    parser.add_argument("--out-dir", default="project/assets/sprites", help="Output directory")
    parser.add_argument("--sprite-width", type=int, default=248)
    parser.add_argument("--sprite-height", type=int, default=248)
    parser.add_argument("--frames", type=int, default=8)
    parser.add_argument("--sheet-cols", type=int, default=4)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    if args.sprite_width < 64 or args.sprite_height < 64:
        raise ValueError("Sprite dimensions must be at least 64×64.")

    sprite_dir = args.out_dir # Standard sprites in root of out-dir as per existing project structure
    sheet_dir = os.path.join(args.out_dir, "sheets")
    meta_dir = os.path.join(args.out_dir, "meta")

    ensure_dir(sprite_dir)
    ensure_dir(sheet_dir)
    ensure_dir(meta_dir)

    specs = CORAL_SPECS + FISH_SPECS

    for spec in specs:
        for style in ["standard", "card", "egg"]:
            frames: List[Image.Image] = []
            for frame_idx in range(args.frames):
                frames.append(draw_sprite(spec, args.sprite_width, args.sprite_height, frame_idx, style=style))

            prefix = f"{spec.slug}"
            if style == "card": prefix = f"{spec.slug}_card"
            elif style == "egg": prefix = f"{spec.slug}_egg"

            for idx, frame in enumerate(frames):
                frame.save(os.path.join(sprite_dir, f"{prefix}_frame_{idx:02d}.png"))

            sheet = build_sheet(frames, args.sheet_cols, args.sprite_width, args.sprite_height)
            sheet_path = os.path.join(sheet_dir, f"{prefix}_sheet.png")
            sheet.save(sheet_path)
            
            # Write Godot .tres file
            write_tres(sprite_dir, prefix, spec.slug, args.frames)

            metadata: Dict[str, object] = {
                "slug": spec.slug,
                "style": style,
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

            meta_filename = f"{prefix}.json"
            with open(os.path.join(meta_dir, meta_filename), "w", encoding="utf-8") as fp:
                json.dump(metadata, fp, indent=2)

        print(f"  {spec.slug} (generated standard, card, egg)")

    write_species_index(args.out_dir, specs, args.sprite_width, args.sprite_height, args.frames, args.sheet_cols)
    print(f"\nGenerated {len(specs)} species (standard/card/egg) in: {args.out_dir}")


if __name__ == "__main__":
    main()
