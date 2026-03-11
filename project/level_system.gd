extends Control

const LEVEL_COUNT := 10
const MAX_FISH_ROWS := 10
const HOME_SCENE := "res://home.tscn"

var controller: Node = null

@onready var status_label: Label = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/StatusLabel
@onready var progress_label: Label = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/ProgressLabel
@onready var objective_label: RichTextLabel = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/ObjectiveLabel
@onready var fish_label: RichTextLabel = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/FishLabel
@onready var levels_grid: GridContainer = get_node_or_null("Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/LevelsGrid")
@onready var fish_actions_box: VBoxContainer = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/FishActionsScroll/FishActionsBox
@onready var next_turn_button: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/ActionsRow/NextTurnButton
@onready var reset_button: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/ActionsRow/ResetButton
@onready var sync_button: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/ActionsRow/SyncButton
@onready var load_button: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/ActionsRow/LoadButton
@onready var breed_button: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/BreedRow/BreedButton
@onready var prev_level_button: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/NavigatorRow/PrevLevelButton
@onready var next_level_nav_button: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/NavigatorRow/NextLevelNavButton
@onready var open_navigator_button: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/NavigatorRow/OpenNavigatorButton
@onready var home_button: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/HomeButton
@onready var block_overlay: Control = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/BlockOverlay
@onready var sand_block_shelf: ColorRect = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/SandBlockShelf
@onready var coral_1: TextureRect = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral1
@onready var coral_2: TextureRect = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral2
@onready var coral_3: TextureRect = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral3
@onready var menu_coral_lab: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/SceneMenuRow/MenuCoralLab
@onready var menu_fish_hatchery: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/SceneMenuRow/MenuFishHatchery
@onready var menu_upgrade_workshop: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/SceneMenuRow/MenuUpgradeWorkshop
@onready var menu_quest_log: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/SceneMenuRow/MenuQuestLog
@onready var menu_map: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/SceneMenuRow/MenuMap
@onready var hub_1: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/Hub1
@onready var hub_2: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/Hub2
@onready var hub_3: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/Hub3
@onready var hub_4: Button = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/Hub4
@onready var fish_a: TextureRect = $Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/BreedRow/FishAGroup/FishA
@onready var fish_b: TextureRect = $Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/BreedRow/FishBGroup/FishB
@onready var fish_c: TextureRect = $Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/BreedRow/FishCGroup/FishC
@onready var fish_swim_1: TextureRect = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/FishSwim1
@onready var fish_swim_2: TextureRect = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/FishSwim2
@onready var fish_swim_3: TextureRect = $Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/FishSwim3

var level_buttons: Array[Button] = []
var fish_rows: Array[Dictionary] = []

# Level state
var _active_level_id := -1
var _level_state: Dictionary = {}
var _level_def: Dictionary = {}

# Simulation state
var _turns_remaining := 0
var _coral_composition: Dictionary = {}   # {coral_species: count} grown so far
var _target_composition: Dictionary = {}  # {coral_species: count} from the reef image
var _match_threshold := 0.75              # fraction required to win
var _match_score := 0.0                   # current intersection score 0..1
var _fishfood_remaining := 0
var _session_over := false

# Fish state
var _fish_population: Dictionary = {}
var _positive_fish: Array = []            # species that produce coral
var _negative_fish: Array = []            # stressors that suppress production
var _available_fish: Array[String] = []   # species the player can recruit mid-level
var _fish_species_order: Array[String] = []

# Constraints and reference data
var _placement_constraints: Dictionary = {}
var _species_reference: Dictionary = {}   # loaded once from AppController
var _active_menu := "Coral Lab"


func _ready() -> void:
	controller = get_node_or_null("/root/AppController")
	_wire_scene_signals()
	call_deferred("_align_coral_to_sand")
	resized.connect(_align_coral_to_sand)
	_start_ambient_animation()
	_connect_controller()
	if controller and controller.has_method("emit_level_state"):
		controller.call("emit_level_state")


func _wire_scene_signals() -> void:
	level_buttons.clear()
	if levels_grid:
		for i in range(1, LEVEL_COUNT + 1):
			var button := levels_grid.get_node_or_null("LevelButton%d" % i) as Button
			if button == null:
				continue
			button.pressed.connect(Callable(self, "_select_level").bind(i))
			level_buttons.append(button)

	fish_rows.clear()
	for i in range(1, MAX_FISH_ROWS + 1):
		var row := fish_actions_box.get_node("FishRow%d" % i) as HBoxContainer
		var species_label := row.get_node("SpeciesLabel") as Label
		var feed_button := row.get_node("FeedButton") as Button
		var net_button := row.get_node("NetButton") as Button
		row.visible = false
		feed_button.pressed.connect(Callable(self, "_on_feed_pressed").bind(i - 1))
		net_button.pressed.connect(Callable(self, "_on_net_pressed").bind(i - 1))
		fish_rows.append({
			"row": row,
			"species_label": species_label,
			"feed_button": feed_button,
			"net_button": net_button,
		})

	next_turn_button.pressed.connect(_advance_turn)
	reset_button.pressed.connect(_reset_level)
	sync_button.pressed.connect(_sync_to_supabase)
	load_button.pressed.connect(_load_from_supabase)
	home_button.pressed.connect(_go_home)
	breed_button.pressed.connect(_on_breed_pressed)
	prev_level_button.pressed.connect(_on_prev_level_pressed)
	next_level_nav_button.pressed.connect(_on_next_level_pressed)
	open_navigator_button.pressed.connect(_on_toggle_blocks_pressed)

	menu_coral_lab.pressed.connect(Callable(self, "_on_menu_pressed").bind("Coral Lab"))
	menu_fish_hatchery.pressed.connect(Callable(self, "_on_menu_pressed").bind("Fish Hatchery"))
	menu_upgrade_workshop.pressed.connect(Callable(self, "_on_menu_pressed").bind("Upgrade Workshop"))
	menu_quest_log.pressed.connect(Callable(self, "_on_menu_pressed").bind("Quest Log"))
	menu_map.pressed.connect(Callable(self, "_on_menu_pressed").bind("Map"))

	hub_1.pressed.connect(Callable(self, "_on_menu_pressed").bind("Coral Lab"))
	hub_2.pressed.connect(Callable(self, "_on_menu_pressed").bind("Fish Hatchery"))
	hub_3.pressed.connect(Callable(self, "_on_menu_pressed").bind("Upgrade Workshop"))
	hub_4.pressed.connect(Callable(self, "_on_menu_pressed").bind("Quest Log"))


func _connect_controller() -> void:
	if controller == null:
		status_label.text = "AppController not found"
		return

	if controller.has_signal("level_progress_changed"):
		controller.level_progress_changed.connect(_on_level_progress_changed)
	if controller.has_signal("supabase_sync_status"):
		controller.supabase_sync_status.connect(_on_supabase_sync_status)

	# Load species reference once — needed for per-fish production rules
	if controller.has_method("get_species_reference_json"):
		var raw := str(controller.call("get_species_reference_json"))
		var parsed = JSON.parse_string(raw)
		if typeof(parsed) == TYPE_DICTIONARY:
			_species_reference = parsed

	status_label.text = "Connected"


func _select_level(level_number: int) -> void:
	if controller and controller.has_method("select_level"):
		controller.call("select_level", level_number)


func _sync_to_supabase() -> void:
	if controller and controller.has_method("sync_progress_to_supabase"):
		controller.call("sync_progress_to_supabase")


func _load_from_supabase() -> void:
	if controller and controller.has_method("load_progress_from_supabase"):
		controller.call("load_progress_from_supabase")


func _on_level_progress_changed(payload_json: String) -> void:
	var parsed = JSON.parse_string(payload_json)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	_level_state = parsed

	var current_level := int(parsed.get("current_level", 1))
	var max_unlocked := int(parsed.get("max_unlocked_level", 1))
	var completed: Array = parsed.get("completed_levels", [])

	for index in range(level_buttons.size()):
		var level := index + 1
		var button := level_buttons[index]
		button.disabled = level > max_unlocked
		if completed.has(level):
			button.text = "Level %d ✔" % level
		elif level == current_level:
			button.text = "Level %d ▶" % level
		else:
			button.text = "Level %d" % level

	if _active_level_id != current_level:
		_start_level_from_state(parsed)
	else:
		_update_text()


func _start_level_from_state(parsed: Dictionary) -> void:
	_active_level_id = int(parsed.get("current_level", 1))
	_level_def = parsed.get("current_level_definition", {})
	if typeof(_level_def) != TYPE_DICTIONARY:
		_level_def = {}

	# Composition target derived from the citizen-science reef image
	_target_composition = _level_def.get("target_composition", {})
	if typeof(_target_composition) != TYPE_DICTIONARY:
		_target_composition = {}
	_match_threshold = float(_level_def.get("match_threshold", 0.75))
	_match_score = 0.0

	_turns_remaining = int(_level_def.get("turn_limit", 6))
	_coral_composition = {}
	_fishfood_remaining = int(parsed.get("current_level_available_fishfood", 0))
	_session_over = false

	_available_fish = _to_string_array(_level_def.get("available_fish", []))
	_placement_constraints = _level_def.get("placement_constraints", {})
	if typeof(_placement_constraints) != TYPE_DICTIONARY:
		_placement_constraints = {}

	_fish_population = {}
	var starting_fish: Dictionary = _level_def.get("starting_fish", {})
	for species in starting_fish.keys():
		_fish_population[str(species)] = int(starting_fish[species])

	_positive_fish = _to_string_array(_level_def.get("positive_fish", []))
	_negative_fish = _to_string_array(_level_def.get("negative_fish", []))

	for species in _positive_fish:
		if not _fish_population.has(species):
			_fish_population[species] = 0
	for species in _negative_fish:
		if not _fish_population.has(species):
			_fish_population[species] = 0
	# Available fish start at 0 — recruited via the Breed button
	for species in _available_fish:
		if not _fish_population.has(species):
			_fish_population[species] = 0

	_fish_species_order = []
	for species in _fish_population.keys():
		_fish_species_order.append(str(species))
	_fish_species_order.sort()

	_refresh_fish_rows()
	status_label.text = "Level %d started" % _active_level_id
	_update_text()


func _to_string_array(value: Variant) -> Array:
	var output: Array = []
	if typeof(value) == TYPE_ARRAY:
		for v in value:
			output.append(str(v))
	return output


func _refresh_fish_rows() -> void:
	for i in range(fish_rows.size()):
		var row_data: Dictionary = fish_rows[i]
		var row: HBoxContainer = row_data["row"]
		var species_label: Label = row_data["species_label"]
		var feed_button: Button = row_data["feed_button"]
		var net_button: Button = row_data["net_button"]

		if i < _fish_species_order.size():
			var species := _fish_species_order[i]
			row.visible = true
			species_label.text = species
			feed_button.text = "+"
			net_button.text = "-"
			feed_button.disabled = _session_over
			net_button.disabled = _session_over
		else:
			row.visible = false


func _align_coral_to_sand() -> void:
	var sand_top := sand_block_shelf.position.y
	for coral in [coral_1, coral_2, coral_3]:
		var c := coral as TextureRect
		if c == null:
			continue
		c.position.y = sand_top - c.size.y + 4.0


func _start_ambient_animation() -> void:
	for fish in [fish_a, fish_b, fish_c]:
		var f := fish as TextureRect
		if f == null:
			continue
		var tw := create_tween().set_loops()
		tw.tween_property(f, "scale", Vector2(1.06, 1.06), 0.9)
		tw.tween_property(f, "scale", Vector2(1.0, 1.0), 0.9)

	for fish in [fish_swim_1, fish_swim_2, fish_swim_3]:
		var f2 := fish as TextureRect
		if f2 == null:
			continue
		var base_pos := f2.position
		var tw2 := create_tween().set_loops()
		tw2.tween_property(f2, "position", base_pos + Vector2(10.0, -4.0), 1.2)
		tw2.tween_property(f2, "position", base_pos + Vector2(-8.0, 3.0), 1.4)
		tw2.tween_property(f2, "position", base_pos, 1.1)

	for coral in [coral_1, coral_2, coral_3]:
		var c2 := coral as TextureRect
		if c2 == null:
			continue
		var tw3 := create_tween().set_loops()
		tw3.tween_property(c2, "rotation_degrees", 2.8, 1.8)
		tw3.tween_property(c2, "rotation_degrees", -2.8, 1.8)
		tw3.tween_property(c2, "rotation_degrees", 0.0, 1.2)


func _on_feed_pressed(index: int) -> void:
	if index >= 0 and index < _fish_species_order.size():
		_adjust_fish(_fish_species_order[index], 1)


func _on_net_pressed(index: int) -> void:
	if index >= 0 and index < _fish_species_order.size():
		_adjust_fish(_fish_species_order[index], -1)


func _adjust_fish(species: String, delta: int) -> void:
	if _session_over:
		return
	if delta > 0 and _fishfood_remaining <= 0:
		status_label.text = "Out of fishfood"
		return

	var current := int(_fish_population.get(species, 0))
	var max_per_species := int(_placement_constraints.get("max_fish_per_species", 99))
	var next_value := clampi(current + delta, 0, max_per_species)
	if next_value == current:
		return

	_fish_population[species] = next_value
	if delta > 0:
		_fishfood_remaining -= 1
	_update_text()


#region Simulation

func _advance_turn() -> void:
	if _session_over:
		return

	# Stressor suppression: each stressor reduces total production
	# suppresses_threshold: species only suppresses above that population count
	var raw_suppression := 0.0
	for species in _negative_fish:
		var count := float(_fish_population.get(species, 0))
		if count <= 0.0:
			continue
		var data := _get_stressor_data(species)
		var threshold := int(data.get("suppresses_threshold", 0))
		if threshold > 0 and count <= float(threshold):
			continue
		raw_suppression += count * float(data.get("suppresses_rate", 0.25))

	var stressor_mult := float(_placement_constraints.get("stressor_multiplier", 1.0))
	var suppression := clampf(raw_suppression * stressor_mult, 0.0, 0.9)

	# Each positive fish produces coral according to its species_reference entry
	for species in _positive_fish:
		var count := float(_fish_population.get(species, 0))
		if count <= 0.0:
			continue
		var data := _get_fish_data(species)
		var produces: Variant = data.get("produces", {})
		if typeof(produces) != TYPE_DICTIONARY:
			continue
		var effective := count * float(data.get("produces_rate", 0.4)) * (1.0 - suppression)
		for coral_species in produces.keys():
			var amount := int(round(effective * float(produces[coral_species])))
			if amount > 0:
				_coral_composition[coral_species] = int(_coral_composition.get(coral_species, 0)) + amount

	# Fish breed passively each turn
	for species in _positive_fish:
		_fish_population[species] = int(_fish_population.get(species, 0)) + 1

	# Stressors grow when their suppression output exceeds half the positive fish count
	if raw_suppression >= float(_positive_fish.size()) * 0.5:
		for species in _negative_fish:
			_fish_population[species] = int(_fish_population.get(species, 0)) + 1

	_fishfood_remaining += 1
	_turns_remaining -= 1
	_match_score = _calculate_match_score()

	if _match_score >= _match_threshold:
		_session_over = true
		var reward := int(_level_def.get("reward_fishfood", 0))
		status_label.text = "Level %d complete! Match: %d%% | +%d fishfood" % [_active_level_id, int(_match_score * 100), reward]
		if controller and controller.has_method("complete_current_level"):
			controller.call("complete_current_level")
		_refresh_fish_rows()
		_update_text()
		return

	if _turns_remaining <= 0:
		_session_over = true
		status_label.text = "Level failed. Match: %d%% (need %d%%). Reset to try again." % [int(_match_score * 100), int(_match_threshold * 100)]
		_refresh_fish_rows()

	_update_text()


func _on_breed_pressed() -> void:
	if _session_over:
		return
	if _fishfood_remaining <= 0:
		status_label.text = "Need fishfood to breed"
		return

	var turn_elapsed := int(_level_def.get("turn_limit", 6)) - _turns_remaining
	var turn_unlock: Dictionary = _placement_constraints.get("turn_unlock", {})
	if typeof(turn_unlock) != TYPE_DICTIONARY:
		turn_unlock = {}
	var max_per_species := int(_placement_constraints.get("max_fish_per_species", 99))

	# Prefer recruiting from available_fish (new species), fall back to positive_fish
	var candidates: Array = _available_fish if not _available_fish.is_empty() else _positive_fish

	for species in candidates:
		if int(turn_unlock.get(species, 0)) > turn_elapsed:
			continue
		var current := int(_fish_population.get(species, 0))
		if current >= max_per_species:
			continue
		_fish_population[species] = current + 1
		if not _fish_species_order.has(species):
			_fish_species_order.append(species)
			_fish_species_order.sort()
		_fishfood_remaining -= 1
		status_label.text = "Bred %s" % species
		_refresh_fish_rows()
		_update_text()
		return

	status_label.text = "No fish available to recruit (cap reached or turn-locked)"

#endregion


func _on_prev_level_pressed() -> void:
	if _active_level_id > 1:
		_select_level(_active_level_id - 1)


func _on_next_level_pressed() -> void:
	if _active_level_id < LEVEL_COUNT:
		_select_level(_active_level_id + 1)


func _on_toggle_blocks_pressed() -> void:
	block_overlay.visible = not block_overlay.visible
	open_navigator_button.text = "Hide Blocks" if block_overlay.visible else "Blocks"


func _go_home() -> void:
	get_tree().change_scene_to_file(HOME_SCENE)


func _on_menu_pressed(menu_name: String) -> void:
	_active_menu = menu_name
	status_label.text = "Mode: %s" % menu_name
	_update_text()


func _reset_level() -> void:
	if _active_level_id <= 0:
		return
	_start_level_from_state(_level_state)


func _update_text() -> void:
	var rewards_total := int(_level_state.get("rewards_total", 0))
	var carryover := int(_level_state.get("carryover_fishfood", 0))
	progress_label.text = "%s | L%d T:%d F:%d R:%d Match:%d%%" % [
		_active_menu, _active_level_id, _turns_remaining,
		_fishfood_remaining, rewards_total + carryover, int(_match_score * 100)
	]

	# Objective panel: target composition (from image) vs coral grown so far
	var level_name := str(_level_def.get("name", "Unknown Level"))
	var zone := str(_level_def.get("zone", ""))
	var header := "[b]%s[/b]" % level_name
	if not zone.is_empty():
		header += "  [%s]" % zone
	header += "  — Match %d%% / need %d%%" % [int(_match_score * 100), int(_match_threshold * 100)]
	var obj_lines := [header]
	for species in _target_composition.keys():
		var target_count := int(_target_composition[species])
		var actual_count := int(_coral_composition.get(species, 0))
		obj_lines.append("  %s  %d / %d" % [species, actual_count, target_count])
	objective_label.text = "\n".join(obj_lines)

	# Fish panel: populations + all coral grown this session
	var fish_lines := ["[b]Fish[/b]"]
	for species in _fish_species_order:
		fish_lines.append("  %s: %d" % [species, int(_fish_population.get(species, 0))])
	fish_lines.append("")
	fish_lines.append("[b]Coral grown[/b]")
	if _coral_composition.is_empty():
		fish_lines.append("  (none yet — advance turn to produce)")
	else:
		for species in _coral_composition.keys():
			fish_lines.append("  %s: %d" % [species, int(_coral_composition[species])])
	fish_label.text = "\n".join(fish_lines)

	next_turn_button.disabled = _session_over
	reset_button.disabled = _active_level_id <= 0


func _on_supabase_sync_status(payload_json: String) -> void:
	var parsed = JSON.parse_string(payload_json)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	status_label.text = "%s: %s" % [str(parsed.get("kind", "")).to_upper(), str(parsed.get("message", ""))]


#region Species lookup

func _get_fish_data(species_name: String) -> Dictionary:
	for entry in _species_reference.get("fish_species", []):
		if str(entry.get("name", "")) == species_name:
			return entry
	return {}


func _get_stressor_data(species_name: String) -> Dictionary:
	for entry in _species_reference.get("stressors", []):
		if str(entry.get("name", "")) == species_name:
			return entry
	return {}

#endregion


#region Match scoring

# Intersection score: sum of min(actual_frac, target_frac) across all target species.
# Reaches 1.0 when the grown composition perfectly matches the target fractions.
func _calculate_match_score() -> float:
	if _target_composition.is_empty():
		return 0.0

	var target_total := 0
	for v in _target_composition.values():
		target_total += int(v)
	if target_total == 0:
		return 0.0

	var actual_total := 0
	for v in _coral_composition.values():
		actual_total += int(v)
	if actual_total == 0:
		return 0.0

	var overlap := 0.0
	for species in _target_composition.keys():
		var t_frac := float(int(_target_composition[species])) / float(target_total)
		var a_frac := float(int(_coral_composition.get(species, 0))) / float(actual_total)
		overlap += minf(t_frac, a_frac)

	return clampf(overlap, 0.0, 1.0)

#endregion
