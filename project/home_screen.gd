extends Control

const LEVEL_COUNT := 10
const GAME_SCENE := "res://scenes/layout/GameScreen.tscn"
const TANK_SCENE := "res://scenes/hub/the_tank.tscn"

var controller: Node = null
@onready var levels_grid: GridContainer = $Background/Margin/Frame/FrameMargin/VBox/LevelsGrid
@onready var status_label: Label = $Background/Margin/Frame/FrameMargin/VBox/StatusLabel

var level_buttons: Array[Button] = []
var _coins_label: Label = null
var _progress_label: Label = null


func _ready() -> void:
	controller = get_node_or_null("/root/AppController")
	_wire()
	_build_extra_ui()
	_refresh_grid_columns()
	resized.connect(_refresh_grid_columns)
	if controller and controller.has_signal("level_progress_changed"):
		controller.level_progress_changed.connect(_on_level_progress_changed)
	if controller and controller.has_method("emit_level_state"):
		controller.call("emit_level_state")


func _wire() -> void:
	for i in range(1, LEVEL_COUNT + 1):
		var b := levels_grid.get_node("LevelButton%d" % i) as Button
		if b == null:
			continue
		b.pressed.connect(Callable(self, "_on_level_pressed").bind(i))
		_style_level_button_base(b)
		level_buttons.append(b)


func _build_extra_ui() -> void:
	# Insert a header row above the level grid with coins + tank button
	var vbox := levels_grid.get_parent() as VBoxContainer
	if vbox == null:
		return

	var header_row := HBoxContainer.new()
	header_row.add_theme_constant_override("separation", 10)
	# Insert directly before the grid so copy/layout changes do not break placement.
	vbox.add_child(header_row)
	vbox.move_child(header_row, levels_grid.get_index())

	var summary_box := VBoxContainer.new()
	summary_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_box.add_theme_constant_override("separation", 4)
	header_row.add_child(summary_box)

	_coins_label = Label.new()
	_coins_label.text = "Reef Bank: 0"
	_coins_label.add_theme_font_size_override("font_size", 17)
	_coins_label.add_theme_color_override("font_color", Color(0.980392, 0.870588, 0.54902, 1))
	summary_box.add_child(_coins_label)

	_progress_label = Label.new()
	_progress_label.text = "Unlocked: 1/10  •  Current: Level 1"
	_progress_label.add_theme_font_size_override("font_size", 14)
	_progress_label.add_theme_color_override("font_color", Color(0.788235, 0.886275, 0.94902, 0.92))
	_progress_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_box.add_child(_progress_label)

	var tank_btn := Button.new()
	tank_btn.text = "The Tank"
	tank_btn.custom_minimum_size = Vector2(132.0, 44.0)
	tank_btn.add_theme_font_size_override("font_size", 15)
	tank_btn.add_theme_color_override("font_color", Color(0.921569, 0.956863, 0.976471, 1))
	tank_btn.add_theme_stylebox_override("normal", _make_panel_style(Color(0.101961, 0.227451, 0.333333, 1), Color(0.25098, 0.627451, 0.745098, 1), 12, 2))
	tank_btn.add_theme_stylebox_override("hover", _make_panel_style(Color(0.121569, 0.286275, 0.411765, 1), Color(0.372549, 0.772549, 0.870588, 1), 12, 2))
	tank_btn.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.0705882, 0.180392, 0.27451, 1), Color(0.239216, 0.580392, 0.701961, 1), 12, 2))
	tank_btn.pressed.connect(_go_to_tank)
	header_row.add_child(tank_btn)


func _on_level_pressed(level_number: int) -> void:
	if controller and controller.has_method("select_level"):
		var ok: bool = controller.call("select_level", level_number)
		if not ok:
			status_label.text = "Level %d is locked" % level_number
			return
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_level_progress_changed(payload_json: String) -> void:
	var parsed = JSON.parse_string(payload_json)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var max_unlocked := int(parsed.get("max_unlocked_level", 1))
	var current_level := int(parsed.get("current_level", 1))
	var completed: Array = parsed.get("completed_levels", [])
	var coins := int(parsed.get("global_coins", 0))
	var pending := int(parsed.get("tank_pending_coins", 0))
	var pending_rewards := int(parsed.get("pending_reward_total", 0))
	var unlocked_count := max_unlocked
	var tutorial_complete := bool(parsed.get("tutorial_complete", false))

	for i in range(level_buttons.size()):
		var level := i + 1
		var b := level_buttons[i]
		b.disabled = level > max_unlocked
		_apply_level_button_state(b, level, completed.has(level), level == current_level, level > max_unlocked)

	if _coins_label:
		if pending > 0 and pending_rewards > 0:
			_coins_label.text = "Reef Bank: %d  (+%d tank, +%d sync)" % [coins, pending, pending_rewards]
		elif pending > 0:
			_coins_label.text = "Reef Bank: %d  (+%d tank)" % [coins, pending]
		elif pending_rewards > 0:
			_coins_label.text = "Reef Bank: %d  (+%d sync)" % [coins, pending_rewards]
		else:
			_coins_label.text = "Reef Bank: %d" % coins
	if _progress_label:
		_progress_label.text = "Unlocked: %d/%d  •  Current: Level %d  •  Cleared: %d" % [unlocked_count, LEVEL_COUNT, current_level, completed.size()]

	if not tutorial_complete:
		status_label.text = "Start with Level 1. It walks you through the game loop."
	else:
		status_label.text = "Choose your next reef site, or visit The Tank to collect idle coins."


func _go_to_tank() -> void:
	get_tree().change_scene_to_file(TANK_SCENE)


func _style_level_button_base(button: Button) -> void:
	button.custom_minimum_size = Vector2(0.0, 84.0)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS


func _apply_level_button_state(button: Button, level: int, is_completed: bool, is_current: bool, is_locked: bool) -> void:
	var badge := "LOCKED"
	var subtitle := "Complete the previous reef to unlock."
	var fill := Color(0.0941176, 0.160784, 0.247059, 1)
	var border := Color(0.168627, 0.294118, 0.423529, 1)
	var font_color := Color(0.592157, 0.678431, 0.760784, 1)

	if is_completed:
		badge = "CLEAR"
		subtitle = "Replay this mission for a cleaner run."
		fill = Color(0.0823529, 0.239216, 0.203922, 1)
		border = Color(0.243137, 0.694118, 0.54902, 1)
		font_color = Color(0.870588, 0.972549, 0.933333, 1)
	elif is_current:
		badge = "LIVE"
		subtitle = "Current mission. Ready to enter."
		fill = Color(0.176471, 0.247059, 0.0901961, 1)
		border = Color(0.772549, 0.835294, 0.356863, 1)
		font_color = Color(0.980392, 0.964706, 0.780392, 1)
	elif not is_locked:
		badge = "READY"
		subtitle = "Unlocked reef site. Begin when ready."
		fill = Color(0.0823529, 0.196078, 0.309804, 1)
		border = Color(0.301961, 0.658824, 0.878431, 1)
		font_color = Color(0.909804, 0.952941, 0.980392, 1)

	button.text = "LEVEL %d   %s\n%s" % [level, badge, subtitle]
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color)
	button.add_theme_color_override("font_pressed_color", font_color)
	button.add_theme_color_override("font_disabled_color", Color(font_color.r * 0.8, font_color.g * 0.8, font_color.b * 0.8, 0.8))
	button.add_theme_stylebox_override("normal", _make_panel_style(fill, border, 14, 2))
	button.add_theme_stylebox_override("hover", _make_panel_style(fill.lightened(0.08), border.lightened(0.12), 14, 2))
	button.add_theme_stylebox_override("pressed", _make_panel_style(fill.darkened(0.08), border, 14, 2))
	button.add_theme_stylebox_override("disabled", _make_panel_style(fill.darkened(0.18), border.darkened(0.18), 14, 2))


func _make_panel_style(fill: Color, border: Color, radius: int, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.content_margin_left = 14.0
	style.content_margin_top = 12.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 12.0
	return style


func _refresh_grid_columns() -> void:
	var board_width := size.x
	if board_width >= 1280.0:
		levels_grid.columns = 5
	elif board_width >= 980.0:
		levels_grid.columns = 4
	elif board_width >= 720.0:
		levels_grid.columns = 3
	else:
		levels_grid.columns = 2
