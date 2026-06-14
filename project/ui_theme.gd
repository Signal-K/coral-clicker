extends Node
class_name UITheme

# ─── Color tokens (Material 3 dark, reef-tactical palette) ───────────────────

const BG             := Color(0.000, 0.063, 0.086, 1.0)  # #001016
const SURFACE        := Color(0.055, 0.078, 0.082, 1.0)  # #0e1415
const SURF_LOW       := Color(0.000, 0.086, 0.114, 1.0)  # #00161d
const SURF_MID       := Color(0.008, 0.114, 0.145, 1.0)  # #021d25
const SURF_HIGH      := Color(0.020, 0.137, 0.173, 1.0)  # #05232c
const SURF_HIGHEST   := Color(0.035, 0.161, 0.200, 1.0)  # #092933

const PRIMARY        := Color(0.322, 0.949, 0.961, 1.0)  # #52f2f5 cyan
const ON_PRIMARY     := Color(0.000, 0.216, 0.224, 1.0)  # #003739
const SECONDARY      := Color(0.996, 0.494, 0.310, 1.0)  # #fe7e4f coral/orange
const TERTIARY       := Color(1.000, 0.906, 0.573, 1.0)  # #ffe792 amber
const ERROR          := Color(1.000, 0.706, 0.671, 1.0)  # #ffb4ab red
const SUCCESS        := Color(0.322, 0.949, 0.961, 1.0)  # same as primary

const ON_SURFACE     := Color(0.867, 0.894, 0.902, 1.0)  # #dde4e6 body text
const ON_SURF_DIM    := Color(0.490, 0.533, 0.553, 1.0)  # muted text
const OUTLINE        := Color(0.251, 0.412, 0.427, 1.0)  # #40696d border
const OUTLINE_VAR    := Color(0.122, 0.298, 0.314, 1.0)  # #1f4c50 subtle border

# Role tint colours (fish card top bars, chip highlights)
const ROLE_POS       := Color(0.322, 0.949, 0.961, 1.0)  # primary — beneficial species
const ROLE_NEG       := Color(1.000, 0.706, 0.671, 1.0)  # error   — harmful/stressor
const ROLE_NEU       := Color(0.490, 0.533, 0.553, 1.0)  # dim     — neutral

# ─── Spacing ─────────────────────────────────────────────────────────────────

const SP_1  :=  4
const SP_2  :=  8
const SP_3  := 12
const SP_4  := 16
const SP_6  := 24
const SP_8  := 32

# ─── Corner radii ────────────────────────────────────────────────────────────

const R_SM   :=  8
const R_MD   := 16
const R_LG   := 24
const R_PILL := 999

# ─── StyleBoxFlat factories ──────────────────────────────────────────────────

static func panel(bg: Color = SURF_MID, border: Color = OUTLINE_VAR,
		border_width: int = 1, radius: int = R_MD) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_width)
	s.set_corner_radius_all(radius)
	return s

static func pill(bg: Color = SURF_HIGH, border: Color = OUTLINE_VAR,
		border_width: int = 1) -> StyleBoxFlat:
	return panel(bg, border, border_width, R_PILL)

# Tactile button — normal state (3-D raised look)
static func btn_normal(bg: Color = SURF_HIGH) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	# Lighter top half → slightly darker bottom via gradient approximation
	s.bg_color = bg.lightened(0.08)
	s.border_color = OUTLINE
	s.set_border_width_all(1)
	s.set_corner_radius_all(R_MD)
	s.shadow_color = Color(0, 0, 0, 0.35)
	s.shadow_size = 3
	s.shadow_offset = Vector2(0, 2)
	s.content_margin_left   = SP_4
	s.content_margin_right  = SP_4
	s.content_margin_top    = SP_3
	s.content_margin_bottom = SP_3
	return s

# Tactile button — pressed state (inset / sunk look)
static func btn_pressed(bg: Color = SURF_HIGH) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg.darkened(0.10)
	s.border_color = OUTLINE_VAR
	s.set_border_width_all(1)
	s.set_corner_radius_all(R_MD)
	s.shadow_color = Color(0, 0, 0, 0.0)
	s.shadow_size = 0
	s.content_margin_left   = SP_4
	s.content_margin_right  = SP_4
	s.content_margin_top    = SP_3 + 2
	s.content_margin_bottom = SP_3 - 2
	return s

# Primary (cyan) button variants
static func btn_primary_normal() -> StyleBoxFlat:
	return btn_normal(PRIMARY.darkened(0.25))

static func btn_primary_pressed() -> StyleBoxFlat:
	return btn_pressed(PRIMARY.darkened(0.35))

# Danger (error/red) button
static func btn_danger_normal() -> StyleBoxFlat:
	return btn_normal(ERROR.darkened(0.40))

static func btn_danger_pressed() -> StyleBoxFlat:
	return btn_pressed(ERROR.darkened(0.50))

# ─── Font size helpers (pt → px at 96dpi) ────────────────────────────────────
# Use add_theme_font_size_override("font_size", UITheme.FS_*)

const FS_XS  := 11
const FS_SM  := 13
const FS_MD  := 15
const FS_LG  := 18
const FS_XL  := 22
const FS_2XL := 28
const FS_3XL := 36
