## Single environment dial — temperature or salinity.
## Draws a conic-gradient arc showing current level (0=low, 1=mid, 2=high).
## Emits changed(delta) of −1 or +1 when the +/− buttons are tapped.
extends Control

signal changed(delta: int)

enum DialType { TEMPERATURE, SALINITY }

@export var dial_type: DialType = DialType.TEMPERATURE
@export var dial_value: int = 1  # 0=low, 1=mid, 2=high
@export var coins_cost: int = 5
@export var trigger_cost: int = 1

@onready var _value_label: Label  = $VBox/Inner/ValueLabel
@onready var _title_label: Label  = $VBox/TitleLabel
@onready var _dec_btn: Button     = $VBox/Buttons/DecBtn
@onready var _inc_btn: Button     = $VBox/Buttons/IncBtn
@onready var _dial_draw: Control  = $VBox/DialDraw

const C_PRIMARY   := Color(0.322, 0.949, 0.961, 1.0)
const C_SECONDARY := Color(0.996, 0.494, 0.310, 1.0)
const C_SURF_HIGH := Color(0.020, 0.137, 0.173, 1.0)
const C_OUTLINE   := Color(0.251, 0.412, 0.427, 1.0)
const C_DIM       := Color(0.490, 0.533, 0.553, 1.0)

var _arc_color: Color

func _ready() -> void:
	_arc_color = C_PRIMARY if dial_type == DialType.TEMPERATURE else C_SECONDARY
	_title_label.text = "TEMP" if dial_type == DialType.TEMPERATURE else "SALIN"
	_dec_btn.pressed.connect(func(): _on_change(-1))
	_inc_btn.pressed.connect(func(): _on_change(1))
	_dec_btn.text = "−"
	_inc_btn.text = "+"
	_update_display()
	_dial_draw.draw.connect(_on_dial_draw)

func set_value(v: int) -> void:
	dial_value = clamp(v, 0, 2)
	_update_display()

func set_insufficient(lack_coins: bool, lack_triggers: bool) -> void:
	# Visual hint when player can't afford adjustment
	_dec_btn.modulate.a = 0.4 if lack_coins or lack_triggers else 1.0
	_inc_btn.modulate.a = 0.4 if lack_coins or lack_triggers else 1.0

func _update_display() -> void:
	var labels_temp  := ["COLD", "WARM", "HOT"]
	var labels_salin := ["LOW",  "MED",  "HIGH"]
	var labels: Array = labels_temp if dial_type == DialType.TEMPERATURE else labels_salin
	_value_label.text = labels[dial_value]
	_value_label.add_theme_color_override("font_color", _arc_color)
	_dec_btn.disabled = dial_value == 0
	_inc_btn.disabled = dial_value == 2
	if _dial_draw:
		_dial_draw.queue_redraw()

func _on_change(_delta: int) -> void:
	changed.emit(_delta)

func _on_dial_draw() -> void:
	var s: Vector2 = _dial_draw.size
	var c: Vector2 = s / 2.0
	var r: float = min(s.x, s.y) / 2.0 - 3.0

	# Background fill
	_dial_draw.draw_circle(c, r, C_SURF_HIGH)

	# Arc segments — 3 positions, draw filled up to dial_value
	var segment_angle: float = PI * 0.6  # total sweep: 216°
	var start_angle: float   = PI + (PI - segment_angle) / 2.0
	for i in range(3):
		var a0: float = start_angle + i * (segment_angle / 3.0)
		var a1: float = a0 + (segment_angle / 3.0) - 0.05
		var col: Color = _arc_color
		if i > dial_value:
			col.a = 0.15
		_dial_draw.draw_arc(c, r - 4.0, a0, a1, 20, col, 5.0, true)

	# Outer ring
	_dial_draw.draw_arc(c, r, 0.0, TAU, 64, C_OUTLINE, 2.0, true)

	# Indicator dot at current position
	var dot_angle: float = start_angle + (dial_value + 0.5) * (segment_angle / 3.0)
	var dot_pos: Vector2 = c + Vector2(cos(dot_angle), sin(dot_angle)) * (r - 4.0)
	_dial_draw.draw_circle(dot_pos, 5.0, _arc_color)
