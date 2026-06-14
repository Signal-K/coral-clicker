extends Control

const UITheme = preload("res://ui_theme.gd")

signal level_selected(level_id: int)

enum State { LOCKED, UNLOCKED, CURRENT, COMPLETED }

@export var level_id: int = 0
@export var level_name: String = ""
@export var node_state: State = State.LOCKED
@export var has_notification: bool = false

@onready var _number_label: Label = $Dial/NumberLabel
@onready var _name_label: Label   = $NameLabel
@onready var _notif_dot: ColorRect = $NotificationDot
@onready var _hit_area: Button    = $HitArea

func _ready() -> void:
	_hit_area.pressed.connect(_on_pressed)
	_hit_area.mouse_entered.connect(func(): _set_hover(true))
	_hit_area.mouse_exited.connect(func(): _set_hover(false))

	_name_label.text = level_name.to_upper()
	_notif_dot.visible = has_notification

	# Icon or number for special nodes
	if level_id == -1:
		_number_label.text = "⚗"
		_number_label.add_theme_font_size_override("font_size", 22)
	elif level_id == 0:
		_number_label.text = "🎓"
		_number_label.add_theme_font_size_override("font_size", 22)
	else:
		_number_label.text = "%02d" % level_id

	_apply_state()
	queue_redraw()

func set_state(s: State) -> void:
	node_state = s
	_apply_state()
	queue_redraw()

func _apply_state() -> void:
	var locked: bool = node_state == State.LOCKED
	_hit_area.disabled = locked
	modulate.a = 0.45 if locked else 1.0

	var label_color: Color
	match node_state:
		State.CURRENT:
			label_color = UITheme.ON_PRIMARY if level_id >= 1 else UITheme.PRIMARY
		State.COMPLETED:
			label_color = UITheme.TERTIARY
		State.UNLOCKED:
			label_color = UITheme.ON_SURFACE
		_:
			label_color = UITheme.ON_SURF_DIM
	
	_number_label.add_theme_color_override("font_color", label_color)
	_name_label.add_theme_color_override("font_color", label_color)

var _hovered: bool = false

func _set_hover(h: bool) -> void:
	_hovered = h
	queue_redraw()

func _draw() -> void:
	var c: Vector2 = size / 2.0
	var r: float = (min(size.x, size.y) - 4.0) / 2.0
	var is_sandbox: bool = level_id == -1

	# Pick ring/fill colours based on node type + state
	var ring_col: Color
	var fill_col: Color

	if is_sandbox:
		ring_col = UITheme.SECONDARY
		fill_col = Color(UITheme.SECONDARY, 0.25) if node_state != State.CURRENT else UITheme.SECONDARY
	else:
		match node_state:
			State.CURRENT:
				ring_col = UITheme.PRIMARY
				fill_col = UITheme.PRIMARY
			State.COMPLETED:
				ring_col = UITheme.TERTIARY
				fill_col = UITheme.SURFACE
			State.UNLOCKED:
				ring_col = Color(UITheme.PRIMARY, 0.6)
				fill_col = UITheme.SURF_MID
			_:
				ring_col = UITheme.OUTLINE
				fill_col = UITheme.SURF_MID

	# Outer glow
	if node_state in [State.CURRENT, State.UNLOCKED] or is_sandbox:
		var glow_col: Color = ring_col
		glow_col.a = 0.2 if _hovered else 0.1
		draw_circle(c, r + 8.0, glow_col)

	# Inner fill
	draw_circle(c, r - 1.0, fill_col)

	# Outer ring (Tactile look: multiple rings)
	var ring_w: float = 3.0 if node_state == State.CURRENT else 2.0
	draw_arc(c, r, 0.0, TAU, 80, ring_col, ring_w, true)
	
	# Middle ring (decoration)
	draw_arc(c, r * 0.85, 0.0, TAU, 72, Color(ring_col, 0.3), 1.0, true)

	# Inner decorative ring
	draw_arc(c, r * 0.72, 0.0, TAU, 64, Color(ring_col, 0.2), 1.0, true)

	# Centre dot
	var dot_col: Color = ring_col
	dot_col.a = 0.7
	draw_circle(c, 3.5, dot_col)

func _on_pressed() -> void:
	if node_state != State.LOCKED:
		level_selected.emit(level_id)
