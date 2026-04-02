extends Control

const LEVEL_COUNT := 10
const GAME_SCENE := "res://scenes/layout/GameScreen.tscn"
const TANK_SCENE := "res://scenes/hub/the_tank.tscn"
const LEVELS_PATH := "res://data/starter_levels.json"
const MAP_POINTS := {
	1: Vector2(0.17, 0.73),
	2: Vector2(0.29, 0.60),
	3: Vector2(0.21, 0.43),
	4: Vector2(0.38, 0.36),
	5: Vector2(0.52, 0.26),
	6: Vector2(0.64, 0.40),
	7: Vector2(0.59, 0.61),
	8: Vector2(0.73, 0.73),
	9: Vector2(0.84, 0.57),
	10: Vector2(0.92, 0.39),
}
const MARKER_TILTS := [-10.0, 8.0, -6.0, 12.0, -8.0, 7.0, -10.0, 9.0, -7.0, 8.0]
const LANDMARK_TILTS := [-14.0, 9.0, -10.0, 12.0, -8.0, 10.0, -12.0, 9.0, -8.0, 11.0]

var controller: Node = null
var level_buttons: Array[Button] = []
var _level_names := {}
var _level_targets := {}
var _level_positive_species := {}
var _level_negative_species := {}
var _marker_labels := {}
var _marker_landmarks := {}
var _route_shadow: Line2D = null
var _route_line: Line2D = null
var _arrow_heads: Array[Polygon2D] = []
var _destination_badge: PanelContainer = null
var _destination_label: Label = null
var _current_level := 1
var _max_unlocked := 1

@onready var layout_root: Control = $Background/Margin/Shell/ShellInset/LayoutRoot
@onready var sidebar: PanelContainer = $Background/Margin/Shell/ShellInset/LayoutRoot/Sidebar
@onready var map_frame: PanelContainer = $Background/Margin/Shell/ShellInset/LayoutRoot/MapFrame
@onready var levels_grid: Control = $Background/Margin/Shell/ShellInset/LayoutRoot/MapFrame/MapInset/MissionMap/LevelsGrid
@onready var path_layer: Node2D = $Background/Margin/Shell/ShellInset/LayoutRoot/MapFrame/MapInset/MissionMap/LevelsGrid/PathLayer
@onready var status_label: Label = $Background/Margin/Shell/ShellInset/LayoutRoot/Sidebar/SidebarMargin/SidebarVBox/StatusLabel
@onready var summary_label: Label = $Background/Margin/Shell/ShellInset/LayoutRoot/Sidebar/SidebarMargin/SidebarVBox/SummaryLabel
@onready var progress_label: Label = $Background/Margin/Shell/ShellInset/LayoutRoot/Sidebar/SidebarMargin/SidebarVBox/ProgressLabel
@onready var tank_button: Button = $Background/Margin/Shell/ShellInset/LayoutRoot/Sidebar/SidebarMargin/SidebarVBox/TankButton


func _ready() -> void:
	controller = get_node_or_null("/root/AppController")
	_load_level_defs()
	_wire()
	_build_route_layer()
	call_deferred("_refresh_layout")
	resized.connect(_refresh_layout)
	tank_button.pressed.connect(_go_to_tank)
	if controller and controller.has_signal("level_progress_changed"):
		controller.level_progress_changed.connect(_on_level_progress_changed)
	if controller and controller.has_method("emit_level_state"):
		controller.call("emit_level_state")


func _load_level_defs() -> void:
	if not FileAccess.file_exists(LEVELS_PATH):
		return
	var file := FileAccess.open(LEVELS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var levels: Variant = parsed.get("levels", [])
	if typeof(levels) != TYPE_ARRAY:
		return
	for entry in levels:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var level_id := int(entry.get("id", 0))
		if level_id <= 0:
			continue
		_level_names[level_id] = str(entry.get("name", "Level %d" % level_id))
		_level_targets[level_id] = str(entry.get("target_coral", ""))
		_level_positive_species[level_id] = _to_string_array(entry.get("positive_fish", []))
		_level_negative_species[level_id] = _to_string_array(entry.get("negative_fish", []))


func _wire() -> void:
	for i in range(1, LEVEL_COUNT + 1):
		var button := levels_grid.get_node_or_null("LevelButton%d" % i) as Button
		if button == null:
			continue
		button.pressed.connect(Callable(self, "_on_level_pressed").bind(i))
		_style_level_button_base(button)
		level_buttons.append(button)

		var landmark := Panel.new()
		landmark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		levels_grid.add_child(landmark)
		levels_grid.move_child(landmark, path_layer.get_index() + 1)
		_marker_landmarks[i] = landmark

		var caption := Label.new()
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption.add_theme_font_size_override("font_size", 14)
		caption.add_theme_color_override("font_color", Color(0.172549, 0.262745, 0.235294, 0.96))
		caption.add_theme_color_override("font_shadow_color", Color(1, 1, 1, 0.45))
		caption.add_theme_constant_override("shadow_offset_x", 0)
		caption.add_theme_constant_override("shadow_offset_y", 1)
		levels_grid.add_child(caption)
		_marker_labels[i] = caption

	_destination_badge = PanelContainer.new()
	_destination_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_destination_badge.visible = false
	_destination_badge.add_theme_stylebox_override("panel", _make_destination_badge_style())
	levels_grid.add_child(_destination_badge)

	var badge_margin := MarginContainer.new()
	badge_margin.add_theme_constant_override("margin_left", 10)
	badge_margin.add_theme_constant_override("margin_top", 4)
	badge_margin.add_theme_constant_override("margin_right", 10)
	badge_margin.add_theme_constant_override("margin_bottom", 4)
	_destination_badge.add_child(badge_margin)

	_destination_label = Label.new()
	_destination_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_destination_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_destination_label.add_theme_font_size_override("font_size", 12)
	_destination_label.add_theme_color_override("font_color", Color(0.180392, 0.176471, 0.0627451, 1))
	badge_margin.add_child(_destination_label)


func _build_route_layer() -> void:
	_route_shadow = Line2D.new()
	_route_shadow.default_color = Color(0.32549, 0.239216, 0.0705882, 0.22)
	_route_shadow.width = 18.0
	_route_shadow.joint_mode = Line2D.LINE_JOINT_ROUND
	_route_shadow.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_route_shadow.end_cap_mode = Line2D.LINE_CAP_ROUND
	path_layer.add_child(_route_shadow)

	_route_line = Line2D.new()
	_route_line.default_color = Color(0.964706, 0.931373, 0.776471, 0.98)
	_route_line.width = 8.0
	_route_line.joint_mode = Line2D.LINE_JOINT_ROUND
	_route_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_route_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	path_layer.add_child(_route_line)

	for _i in range(LEVEL_COUNT - 1):
		var arrow := Polygon2D.new()
		arrow.color = Color(0.964706, 0.931373, 0.776471, 0.98)
		path_layer.add_child(arrow)
		_arrow_heads.append(arrow)


func _refresh_layout() -> void:
	var compact := size.x < 1040.0
	var root_size := layout_root.size
	if root_size.x <= 0.0 or root_size.y <= 0.0:
		call_deferred("_refresh_layout")
		return

	if compact:
		var sidebar_height := clampf(root_size.y * 0.27, 210.0, 260.0)
		sidebar.position = Vector2.ZERO
		sidebar.size = Vector2(root_size.x, sidebar_height)
		map_frame.position = Vector2(0.0, sidebar_height + 16.0)
		map_frame.size = Vector2(root_size.x, max(260.0, root_size.y - sidebar_height - 16.0))
	else:
		var sidebar_width := clampf(root_size.x * 0.29, 290.0, 360.0)
		sidebar.position = Vector2.ZERO
		sidebar.size = Vector2(sidebar_width, root_size.y)
		map_frame.position = Vector2(sidebar_width + 16.0, 0.0)
		map_frame.size = Vector2(max(360.0, root_size.x - sidebar_width - 16.0), root_size.y)

	_position_level_buttons()
	_refresh_route_points()


func _position_level_buttons() -> void:
	var board_size := levels_grid.size
	if board_size.x <= 0.0 or board_size.y <= 0.0:
		call_deferred("_refresh_layout")
		return

	var compact := board_size.x < 720.0
	var marker_size := Vector2(58.0, 58.0) if not compact else Vector2(50.0, 50.0)
	var coral_size := Vector2(96.0, 72.0) if not compact else Vector2(82.0, 62.0)
	var label_size := Vector2(116.0, 42.0) if not compact else Vector2(96.0, 36.0)

	for i in range(level_buttons.size()):
		var level := i + 1
		var point: Vector2 = MAP_POINTS.get(level, Vector2(0.5, 0.5))
		var center := Vector2(board_size.x * point.x, board_size.y * point.y)

		var landmark: Panel = _marker_landmarks.get(level, null)
		if landmark != null:
			landmark.size = coral_size
			landmark.position = center - coral_size * 0.5
			landmark.rotation_degrees = LANDMARK_TILTS[i]

		var button := level_buttons[i]
		button.size = marker_size
		button.position = center - marker_size * 0.5
		button.rotation_degrees = MARKER_TILTS[i]

		var caption: Label = _marker_labels.get(level, null)
		if caption != null:
			caption.size = label_size
			caption.position = center + Vector2(-label_size.x * 0.5, marker_size.y * 0.55)

	_position_destination_badge()


func _refresh_route_points() -> void:
	if _route_line == null or _route_shadow == null:
		return

	var points: PackedVector2Array = []
	for button in level_buttons:
		points.append(button.position + button.size * 0.5)
	_route_shadow.points = points
	_route_line.points = points

	for i in range(_arrow_heads.size()):
		if i >= points.size() - 1:
			_arrow_heads[i].visible = false
			continue
		var start := points[i]
		var finish := points[i + 1]
		var direction := (finish - start).normalized()
		var normal := Vector2(-direction.y, direction.x)
		var tip := finish - direction * 28.0
		var base := tip - direction * 16.0
		_arrow_heads[i].polygon = PackedVector2Array([
			tip,
			base + normal * 9.0,
			base - normal * 9.0,
		])
		_arrow_heads[i].visible = true


func _on_level_pressed(level_number: int) -> void:
	if controller and controller.has_method("select_level"):
		var ok: bool = controller.call("select_level", level_number)
		if not ok:
			status_label.text = "%s is still locked." % _level_short_name(level_number)
			return
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_level_progress_changed(payload_json: String) -> void:
	var parsed = JSON.parse_string(payload_json)
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var max_unlocked := int(parsed.get("max_unlocked_level", 1))
	var current_level := int(parsed.get("current_level", 1))
	_max_unlocked = max_unlocked
	_current_level = current_level
	var completed: Array = parsed.get("completed_levels", [])
	var coins := int(parsed.get("global_coins", 0))
	var carryover_triggers := int(parsed.get("carryover_triggers", 0))
	var pending := int(parsed.get("tank_pending_coins", 0))
	var pending_rewards := int(parsed.get("pending_reward_total", 0))
	var tutorial_complete := bool(parsed.get("tutorial_complete", false))

	for i in range(level_buttons.size()):
		var level := i + 1
		var is_locked := level > max_unlocked
		var button := level_buttons[i]
		button.disabled = is_locked
		_apply_level_button_state(button, level, completed.has(level), level == current_level, is_locked)

	var reserve_text := "  |  Action reserve: %d" % carryover_triggers if carryover_triggers > 0 else ""
	if not tutorial_complete:
		summary_label.text = "Reef Bank: %d%s" % [coins, reserve_text]
	elif pending > 0 and pending_rewards > 0:
		summary_label.text = "Reef Bank: %d  (+%d tank ready, +%d mission cache)%s" % [coins, pending, pending_rewards, reserve_text]
	elif pending > 0:
		summary_label.text = "Reef Bank: %d  (+%d tank ready)%s" % [coins, pending, reserve_text]
	elif pending_rewards > 0:
		summary_label.text = "Reef Bank: %d  (+%d mission cache)%s" % [coins, pending_rewards, reserve_text]
	else:
		summary_label.text = "Reef Bank: %d%s" % [coins, reserve_text]

	progress_label.text = "Unlocked: %d/%d  |  Current: %s  |  Cleared: %d" % [
		max_unlocked,
		LEVEL_COUNT,
		_level_short_name(current_level),
		completed.size(),
	]

	if not tutorial_complete:
		status_label.text = _tutorial_home_status(current_level)
	else:
		status_label.text = "Follow the coral route east for trickier reefs, or visit The Tank to cash out and tune your sanctuary."
		if carryover_triggers > 0:
			status_label.text += " You have %d stored action reserve for the next mission." % carryover_triggers

	call_deferred("_refresh_layout")


func _style_level_button_base(button: Button) -> void:
	button.custom_minimum_size = Vector2(58.0, 58.0)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.focus_mode = Control.FOCUS_NONE


func _apply_level_button_state(button: Button, level: int, is_completed: bool, is_current: bool, is_locked: bool) -> void:
	var bubble_fill := Color(0.513726, 0.556863, 0.603922, 0.96)
	var bubble_border := Color(0.286275, 0.317647, 0.352941, 1.0)
	var bubble_text := Color(0.964706, 0.972549, 0.984314, 1.0)
	var coral_fill := Color(0.52549, 0.552941, 0.588235, 0.88)
	var coral_border := Color(0.270588, 0.298039, 0.337255, 1.0)

	if is_completed:
		bubble_fill = Color(0.984314, 0.67451, 0.207843, 1.0)
		bubble_border = Color(0.792157, 0.4, 0.0784314, 1.0)
		bubble_text = Color(0.262745, 0.145098, 0.027451, 1.0)
		coral_fill = Color(0.972549, 0.47451, 0.211765, 0.96)
		coral_border = Color(0.717647, 0.223529, 0.0745098, 1.0)
	elif is_current:
		bubble_fill = Color(0.996078, 0.882353, 0.337255, 1.0)
		bubble_border = Color(0.796078, 0.603922, 0.141176, 1.0)
		bubble_text = Color(0.254902, 0.203922, 0.0470588, 1.0)
		coral_fill = Color(0.960784, 0.580392, 0.427451, 0.96)
		coral_border = Color(0.741176, 0.333333, 0.215686, 1.0)
	elif not is_locked:
		bubble_fill = Color(0.968627, 0.415686, 0.580392, 1.0)
		bubble_border = Color(0.74902, 0.172549, 0.360784, 1.0)
		bubble_text = Color(1.0, 0.976471, 0.984314, 1.0)
		coral_fill = Color(0.337255, 0.854902, 0.741176, 0.94)
		coral_border = Color(0.113725, 0.560784, 0.454902, 1.0)

	button.text = str(level)
	button.tooltip_text = str(_level_names.get(level, "Level %d" % level))
	button.add_theme_font_size_override("font_size", 22 if levels_grid.size.x >= 720.0 else 18)
	button.add_theme_color_override("font_color", bubble_text)
	button.add_theme_color_override("font_hover_color", bubble_text)
	button.add_theme_color_override("font_pressed_color", bubble_text)
	button.add_theme_color_override("font_disabled_color", Color(bubble_text.r * 0.9, bubble_text.g * 0.9, bubble_text.b * 0.9, 0.84))
	button.add_theme_stylebox_override("normal", _make_bubble_style(bubble_fill, bubble_border))
	button.add_theme_stylebox_override("hover", _make_bubble_style(bubble_fill.lightened(0.08), bubble_border.lightened(0.04)))
	button.add_theme_stylebox_override("pressed", _make_bubble_style(bubble_fill.darkened(0.08), bubble_border))
	button.add_theme_stylebox_override("disabled", _make_bubble_style(bubble_fill.darkened(0.12), bubble_border.darkened(0.08)))

	var caption: Label = _marker_labels.get(level, null)
	if caption != null:
		caption.text = _level_short_name(level)
		caption.add_theme_font_size_override("font_size", 14 if levels_grid.size.x >= 720.0 else 12)
		caption.add_theme_color_override("font_color", Color(0.145098, 0.247059, 0.211765, 0.96) if not is_locked else Color(0.258824, 0.286275, 0.329412, 0.96))

	var landmark: Panel = _marker_landmarks.get(level, null)
	if landmark != null:
		landmark.add_theme_stylebox_override("panel", _make_coral_style(coral_fill, coral_border))


func _make_bubble_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.corner_radius_top_left = 30
	style.corner_radius_top_right = 30
	style.corner_radius_bottom_right = 30
	style.corner_radius_bottom_left = 30
	style.shadow_color = Color(0, 0, 0, 0.16)
	style.shadow_size = 5
	return style


func _make_coral_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.corner_radius_top_left = 34
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_right = 30
	style.corner_radius_bottom_left = 26
	style.shadow_color = Color(0, 0, 0, 0.14)
	style.shadow_size = 6
	return style


func _make_destination_badge_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.945098, 0.635294, 0.96)
	style.border_color = Color(0.772549, 0.588235, 0.14902, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_right = 16
	style.corner_radius_bottom_left = 16
	style.shadow_color = Color(0, 0, 0, 0.12)
	style.shadow_size = 4
	return style


func _position_destination_badge() -> void:
	if _destination_badge == null or level_buttons.is_empty():
		return
	var index := clampi(_current_level - 1, 0, level_buttons.size() - 1)
	if index < 0 or index >= level_buttons.size():
		_destination_badge.visible = false
		return
	var button := level_buttons[index]
	if button == null:
		_destination_badge.visible = false
		return
	var compact := levels_grid.size.x < 720.0
	_destination_label.text = "Current Reef" if _current_level <= _max_unlocked else "Next Reef"
	_destination_badge.custom_minimum_size = Vector2(96.0, 28.0) if not compact else Vector2(82.0, 24.0)
	_destination_badge.size = _destination_badge.custom_minimum_size
	_destination_badge.position = button.position + Vector2(button.size.x * 0.5 - _destination_badge.size.x * 0.5, -34.0 if not compact else -28.0)
	_destination_badge.visible = true


func _level_short_name(level: int) -> String:
	var full_name := str(_level_names.get(level, "Level %d" % level))
	var parts := full_name.split(" ")
	if parts.size() >= 2:
		return "%s\n%s" % [parts[0], parts[1]]
	return full_name


func _go_to_tank() -> void:
	get_tree().change_scene_to_file(TANK_SCENE)


func _tutorial_home_status(level: int) -> String:
	var target := str(_level_targets.get(level, "the target coral"))
	var helpers: Array = _level_positive_species.get(level, [])
	var threats: Array = _level_negative_species.get(level, [])
	var helper_text := ""
	if not helpers.is_empty():
		helper_text = str(helpers[0])
		if helpers.size() > 1:
			helper_text = "%s and %s" % [helpers[0], helpers[1]]
	if helper_text.is_empty():
		helper_text = "your helper fish"
	var threat_text := str(threats[0]) if not threats.is_empty() else "harmful species"
	return "Start at %s. %s help %s grow, while %s push the reef the wrong way." % [_level_names.get(level, "Shallow Bloom"), helper_text, target, threat_text]


func _to_string_array(value: Variant) -> Array:
	var output: Array = []
	if typeof(value) == TYPE_ARRAY:
		for entry in value:
			output.append(str(entry))
	return output
