extends Control

const LEVEL_COUNT := 10
const GAME_SCENE := "res://main.tscn"

var controller: Node = null
@onready var levels_grid: GridContainer = $Background/Margin/Frame/FrameMargin/VBox/LevelsGrid
@onready var status_label: Label = $Background/Margin/Frame/FrameMargin/VBox/StatusLabel

var level_buttons: Array[Button] = []

func _ready() -> void:
	controller = get_node_or_null("/root/AppController")
	_wire()
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
		level_buttons.append(b)


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

	for i in range(level_buttons.size()):
		var level := i + 1
		var b := level_buttons[i]
		b.disabled = level > max_unlocked
		if completed.has(level):
			b.text = "Level %d ✔" % level
		elif level == current_level:
			b.text = "Level %d ▶" % level
		else:
			b.text = "Level %d" % level

	status_label.text = "Select a level"
