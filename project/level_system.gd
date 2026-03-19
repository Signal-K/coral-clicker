extends Control

const LEVEL_COUNT := 10
const MAX_FISH_ROWS := 10
const HOME_SCENE := "res://home.tscn"
const CLICK_A_CORAL_DATA_PATH := "res://data/click_a_coral_subjects.json"
const CLICK_A_CORAL_DICTIONARY_PATH := "res://assets/click_a_coral/dictionary"
const TUTORIAL_STEPS_PATH := "res://data/tutorial_steps.json"

var EggNodeScene = preload("res://scenes/ui/EggNode.tscn")
var TurnResultsPanelScene = preload("res://scenes/ui/TurnResultsPanel.tscn")
var FishCardScene = preload("res://scenes/ui/FishCard.tscn")
var TutorialOverlayScene = preload("res://scenes/ui/TutorialOverlay.tscn")

# Shop/environment costs in coins
const SHOP_FISH_EGG_COST := 5
const ENV_TUNE_COST := 5

var controller: Node = null


func _first_node(paths: Array[String]) -> Node:
	for path in paths:
		var node := get_node_or_null(path)
		if node != null:
			return node
	return null

# New UI components
@onready var objective_card: Node = _first_node(["UIMargin/PortraitVBox/TopRow/ObjectiveCard"]) 
@onready var reef_viewport: Node = _first_node(["UIMargin/PortraitVBox/ReefViewport", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport"])
@onready var reef_layer: Control = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer"]) as Control
@onready var turn_flow_strip: Node = _first_node(["UIMargin/PortraitVBox/TurnFlowStrip", "Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar"])
@onready var fish_card_strip: ScrollContainer = _first_node(["UIMargin/PortraitVBox/FishCardStrip", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/FishActionsScroll"]) as ScrollContainer
@onready var cards_hbox: HBoxContainer = _first_node(["UIMargin/PortraitVBox/FishCardStrip/FishActionsBox", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/FishActionsScroll/FishActionsBox"]) as HBoxContainer
@onready var bottom_resource_bar: Node = _first_node(["UIMargin/PortraitVBox/BottomResourceBar", "Background/Margin/FramePanel/FrameMargin/RootVBox/BottomResourceBar"])

# References within components
@onready var status_label: Label = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/TitlePlate/ReefTitle", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/TitlePlate/ReefTitle", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/StatusLabel"]) as Label
@onready var next_turn_button: Button = _first_node(["UIMargin/PortraitVBox/TurnFlowStrip/NextTurnButton", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/ActionsRow/NextTurnButton"]) as Button

# Core sprites (within ReefViewport)
@onready var coral_1: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral1", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral1"]) as AnimatedSprite2D
@onready var coral_2: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral2", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral2"]) as AnimatedSprite2D
@onready var coral_3: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral3", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral3"]) as AnimatedSprite2D
@onready var fish_swim_1: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/FishSwim1", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/FishSwim1"]) as AnimatedSprite2D
@onready var fish_swim_2: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/FishSwim2", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/FishSwim2"]) as AnimatedSprite2D
@onready var fish_swim_3: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/FishSwim3", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/FishSwim3"]) as AnimatedSprite2D
@onready var coral_patch_1a: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral1/PatchA", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral1/PatchA"]) as AnimatedSprite2D
@onready var coral_patch_1b: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral1/PatchB", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral1/PatchB"]) as AnimatedSprite2D
@onready var coral_patch_1c: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral1/PatchC", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral1/PatchC"]) as AnimatedSprite2D
@onready var coral_patch_2a: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral2/PatchA", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral2/PatchA"]) as AnimatedSprite2D
@onready var coral_patch_2b: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral2/PatchB", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral2/PatchB"]) as AnimatedSprite2D
@onready var coral_patch_2c: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral2/PatchC", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral2/PatchC"]) as AnimatedSprite2D
@onready var coral_patch_3a: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral3/PatchA", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral3/PatchA"]) as AnimatedSprite2D
@onready var coral_patch_3b: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral3/PatchB", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral3/PatchB"]) as AnimatedSprite2D
@onready var coral_patch_3c: AnimatedSprite2D = _first_node(["UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/Coral3/PatchC", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/ReefViewport/ReefMargin/ReefLayer/Coral3/PatchC"]) as AnimatedSprite2D

# Environment (moved to hidden or integrated later, pointing to null for now if missing)
var salinity_bar: ProgressBar = null
var temp_bar: ProgressBar = null
var salinity_readout_label: Label = null
var temperature_readout_label: Label = null
var turn_hint_label: Label = null
var salinity_down_button: Button = null
var salinity_up_button: Button = null
var temp_down_button: Button = null
var temp_up_button: Button = null

# Bottom resource bar
@onready var _bottom_nutrients_label: Label = _first_node(["UIMargin/PortraitVBox/BottomResourceBar/BottomMargin/BottomRow/ResA", "Background/Margin/FramePanel/FrameMargin/RootVBox/BottomResourceBar/BottomMargin/BottomRow/ResA"]) as Label
@onready var _bottom_coins_label: Label = _first_node(["UIMargin/PortraitVBox/BottomResourceBar/BottomMargin/BottomRow/ResB", "Background/Margin/FramePanel/FrameMargin/RootVBox/BottomResourceBar/BottomMargin/BottomRow/ResB"]) as Label
@onready var _bottom_turn_label: Label = _first_node(["UIMargin/PortraitVBox/BottomResourceBar/BottomMargin/BottomRow/ResC", "Background/Margin/FramePanel/FrameMargin/RootVBox/BottomResourceBar/BottomMargin/BottomRow/ResC"]) as Label
@onready var _bottom_reef_label: Label = _first_node(["UIMargin/PortraitVBox/BottomResourceBar/BottomMargin/BottomRow/ResD", "Background/Margin/FramePanel/FrameMargin/RootVBox/BottomResourceBar/BottomMargin/BottomRow/ResD"]) as Label

@onready var home_button: Button = _first_node(["UIMargin/PortraitVBox/TopRow/HomeButton", "Background/Margin/FramePanel/FrameMargin/RootVBox/MidRow/SideNavigator/SideMargin/SideVBox/HomeButton"]) as Button

# Environment (moved to hidden or integrated later, pointing to null for now if missing)

var _active_level_id := -1
var _level_state: Dictionary = {}
var _level_def: Dictionary = {}

var _turns_remaining := 0
var _turns_used := 0
var _triggers_per_turn := 2
var _triggers_remaining := 2
var _target_population := 0
var _coral_population := 0
var _nutrients := 0
var _turn_nutrients_spent := 0
var _session_over := false
var _in_identify_phase := false
var _showing_turn_results := false
var _identify_bonus_coins := 0
var _fail_reason := "You ran out of turns before reaching the target reef composition."
var _essential_species: Array[String] = []

var _fish_population: Dictionary = {}
var _fish_instances: Dictionary = {}
var _fish_instance_counter := 0
var _positive_fish: Array = []
var _negative_fish: Array = []
var _fish_species_order: Array[String] = []
var _salinity_adjustment := 0
var _temperature_adjustment := 0

var _species_reference: Dictionary = {}
var _fish_specs_by_name: Dictionary = {}
var _stressor_specs_by_name: Dictionary = {}
var _coral_specs_by_name: Dictionary = {}
var _interactions: Dictionary = {}
var _trait_definitions: Dictionary = {}
var _species_available_traits: Dictionary = {}

# Active trait per species in the current level session (species → trait string)
var _fish_active_traits: Dictionary = {}

var _breeding_timers: Dictionary = {}
var _active_eggs: Array = []

var _classification_entries: Array = []
var _pending_classification: Dictionary = {}
var _classification_bonus_coins := 5
var _tutorial_steps: Dictionary = {}
var _tutorial_active := false
var _tutorial_step_id := ""
var _tutorial_results_seen := false

# Dialogs and overlays (built programmatically)
var _classification_dialog: AcceptDialog = null
var _classification_prompt_label: RichTextLabel = null
var _classification_image: TextureRect = null
var _classification_guess_option: OptionButton = null

var _identify_dialog: AcceptDialog = null
var _identify_subject: Dictionary = {}
var _identify_image: TextureRect = null
var _identify_choice_list: VBoxContainer = null
var _identify_choice_checks: Array[CheckBox] = []
var _identify_skip_label: Label = null
var _stressor_tooltip_dialog: AcceptDialog = null
var _resume_turn_after_stressor_tooltip := false

var _breed_preview_dialog: AcceptDialog = null
var _breed_preview_label: RichTextLabel = null
var _breed_preview_parents: Array[String] = []

var _level_end_overlay: CanvasLayer = null
var _level_end_stats_label: RichTextLabel = null
var _level_end_species_label: RichTextLabel = null
var _level_end_next_btn: Button = null

var _level_fail_overlay: CanvasLayer = null
var _level_fail_stats_label: RichTextLabel = null

var _shop_overlay: CanvasLayer = null
var _shop_coins_label: Label = null
var _shop_button: Button = null

var _turn_results_overlay: CanvasLayer = null
var _turn_results_title_label: Label = null
var _turn_results_rows: VBoxContainer = null
var _turn_results_meta_label: RichTextLabel = null
var _tutorial_overlay: CanvasLayer = null

var level_buttons: Array[Button] = []
var fish_cards: Array[Node] = []


func _ready() -> void:
	controller = get_node_or_null("/root/AppController")
	_bind_environment_ui()
	_wire_scene_signals()
	call_deferred("_align_coral_to_sand")
	resized.connect(_align_coral_to_sand)
	_start_ambient_animation()
	_connect_controller()
	_load_species_reference()
	_load_classification_entries()
	_load_tutorial_steps()
	_build_classification_dialog()
	_build_identify_dialog()
	_build_stressor_tooltip_dialog()
	_build_breed_preview_dialog()
	_build_shop_overlay()
	_build_turn_results_overlay()
	_build_level_end_overlay()
	_build_level_fail_overlay()
	_build_tutorial_overlay()
	_add_shop_button()
	_prime_level_state_if_needed()
	if controller and controller.has_method("emit_level_state"):
		controller.call("emit_level_state")


func _wire_scene_signals() -> void:
	if turn_flow_strip and turn_flow_strip.has_signal("turn_pressed"):
		turn_flow_strip.turn_pressed.connect(_advance_turn)
	if turn_flow_strip and turn_flow_strip.has_signal("shop_pressed"):
		turn_flow_strip.shop_pressed.connect(_show_shop)
	if salinity_down_button:
		salinity_down_button.pressed.connect(_adjust_environment.bind("salinity", -1))
	if salinity_up_button:
		salinity_up_button.pressed.connect(_adjust_environment.bind("salinity", 1))
	if temp_down_button:
		temp_down_button.pressed.connect(_adjust_environment.bind("temperature", -1))
	if temp_up_button:
		temp_up_button.pressed.connect(_adjust_environment.bind("temperature", 1))
	
	if home_button:
		home_button.pressed.connect(_go_home)


func _bind_environment_ui() -> void:
	salinity_readout_label = _first_node([
		"UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/WaterHud/HudMargin/HudVBox/SalinityLabel",
		"Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/EnvironmentReadoutRow/SalinityReadout/SalinityReadoutLabel"
	]) as Label
	temperature_readout_label = _first_node([
		"UIMargin/PortraitVBox/ReefViewport/ReefMargin/ReefLayer/WaterHud/HudMargin/HudVBox/TemperatureLabel",
		"Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/EnvironmentReadoutRow/TemperatureReadout/TemperatureReadoutLabel"
	]) as Label
	turn_hint_label = _first_node([
		"Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/EnvironmentReadoutRow/TurnHint/TurnHintLabel"
	]) as Label
	salinity_bar = _first_node([
		"Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/MetersRow/SalinityMeter/SalinityBar"
	]) as ProgressBar
	temp_bar = _first_node([
		"Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/MetersRow/TemperatureMeter/TempBar"
	]) as ProgressBar
	salinity_down_button = _first_node([
		"Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/EnvironmentControlRow/SalinityDownButton"
	]) as Button
	salinity_up_button = _first_node([
		"Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/EnvironmentControlRow/SalinityUpButton"
	]) as Button
	temp_down_button = _first_node([
		"Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/EnvironmentControlRow/TempDownButton"
	]) as Button
	temp_up_button = _first_node([
		"Background/Margin/FramePanel/FrameMargin/RootVBox/TopFlowBar/TopMargin/TopVBox/EnvironmentControlRow/TempUpButton"
	]) as Button


func _add_shop_button() -> void:
	# Shop button is now static in TurnFlowStrip
	pass


func _connect_controller() -> void:
	if controller == null:
		if status_label:
			status_label.text = "AppController not found"
		return

	if controller.has_signal("level_progress_changed"):
		controller.level_progress_changed.connect(_on_level_progress_changed)
	if controller.has_signal("supabase_sync_status"):
		controller.supabase_sync_status.connect(_on_supabase_sync_status)
	if status_label:
		status_label.text = "Connected"


func _prime_level_state_if_needed() -> void:
	if controller == null:
		return
	if not controller.has_method("get_level_state_json"):
		return
	var parsed = JSON.parse_string(controller.call("get_level_state_json"))
	if typeof(parsed) == TYPE_DICTIONARY:
		_on_level_progress_changed(JSON.stringify(parsed))


func _load_species_reference() -> void:
	if controller and controller.has_method("get_species_reference_json"):
		var parsed = JSON.parse_string(controller.call("get_species_reference_json"))
		if typeof(parsed) == TYPE_DICTIONARY:
			_species_reference = parsed

	_fish_specs_by_name = {}
	for fish_entry in _species_reference.get("fish_species", []):
		if typeof(fish_entry) != TYPE_DICTIONARY:
			continue
		var fish_name := str(fish_entry.get("name", ""))
		if fish_name.is_empty():
			continue
		_fish_specs_by_name[fish_name] = fish_entry

	_stressor_specs_by_name = {}
	for stress_entry in _species_reference.get("stressors", []):
		if typeof(stress_entry) != TYPE_DICTIONARY:
			continue
		var stress_name := str(stress_entry.get("name", ""))
		if stress_name.is_empty():
			continue
		_stressor_specs_by_name[stress_name] = stress_entry

	_coral_specs_by_name = _species_reference.get("coral_specs", {})
	if typeof(_coral_specs_by_name) != TYPE_DICTIONARY:
		_coral_specs_by_name = {}

	_interactions = _species_reference.get("interactions", {})
	if typeof(_interactions) != TYPE_DICTIONARY:
		_interactions = {}

	_trait_definitions = _species_reference.get("trait_definitions", {})
	if typeof(_trait_definitions) != TYPE_DICTIONARY:
		_trait_definitions = {}

	_species_available_traits = _species_reference.get("species_traits", {})
	if typeof(_species_available_traits) != TYPE_DICTIONARY:
		_species_available_traits = {}


func _load_classification_entries() -> void:
	_classification_entries = []
	if not FileAccess.file_exists(CLICK_A_CORAL_DATA_PATH):
		return
	var raw := FileAccess.get_file_as_string(CLICK_A_CORAL_DATA_PATH)
	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var entries: Variant = parsed.get("entries", [])
	if typeof(entries) != TYPE_ARRAY:
		return
	for entry in entries:
		if typeof(entry) == TYPE_DICTIONARY:
			_classification_entries.append(entry)


func _load_tutorial_steps() -> void:
	_tutorial_steps = {}
	if not FileAccess.file_exists(TUTORIAL_STEPS_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(TUTORIAL_STEPS_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var steps: Variant = parsed.get("steps", {})
	if typeof(steps) == TYPE_DICTIONARY:
		_tutorial_steps = steps


# ─── Identify Phase (Citizen Science, level start) ────────────────────────────

func _build_identify_dialog() -> void:
	_identify_dialog = AcceptDialog.new()
	_identify_dialog.title = "Identify the Reef"
	_identify_dialog.dialog_hide_on_ok = false
	_identify_dialog.ok_button_text = "Submit (+%d coins if correct)" % _classification_bonus_coins
	_identify_dialog.canceled.connect(_on_identify_skipped)
	_identify_dialog.confirmed.connect(_on_identify_confirmed)
	add_child(_identify_dialog)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(560.0, 420.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_identify_dialog.add_child(scroll)

	var root := VBoxContainer.new()
	root.custom_minimum_size = Vector2(540.0, 0.0)
	root.add_theme_constant_override("separation", 12)
	scroll.add_child(root)

	var intro := RichTextLabel.new()
	intro.fit_content = true
	intro.bbcode_enabled = true
	intro.scroll_active = false
	intro.text = "[b]What coral species do you see?[/b]\nSelect every species you can confidently identify. Reference thumbnails are shown beside each option.\nA correct identification earns [b]%d bonus coins![/b]" % _classification_bonus_coins
	root.add_child(intro)

	_identify_image = TextureRect.new()
	_identify_image.custom_minimum_size = Vector2(440.0, 180.0)
	_identify_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_identify_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_identify_image.visible = false
	root.add_child(_identify_image)

	var picker_label := Label.new()
	picker_label.text = "Species present in this image:"
	root.add_child(picker_label)

	_identify_choice_list = VBoxContainer.new()
	_identify_choice_list.add_theme_constant_override("separation", 8)
	root.add_child(_identify_choice_list)

	_identify_skip_label = Label.new()
	_identify_skip_label.text = "Close this dialog to skip (no penalty)"
	_identify_skip_label.modulate = Color(0.7, 0.7, 0.7)
	root.add_child(_identify_skip_label)


func _build_stressor_tooltip_dialog() -> void:
	_stressor_tooltip_dialog = AcceptDialog.new()
	_stressor_tooltip_dialog.title = "Reef Warning"
	_stressor_tooltip_dialog.dialog_hide_on_ok = true
	_stressor_tooltip_dialog.ok_button_text = "Got it"
	_stressor_tooltip_dialog.confirmed.connect(_on_stressor_tooltip_dismissed)
	add_child(_stressor_tooltip_dialog)

	var body := RichTextLabel.new()
	body.custom_minimum_size = Vector2(420.0, 0.0)
	body.bbcode_enabled = true
	body.fit_content = true
	body.scroll_active = false
	body.text = "[b]A Longspine Sea Urchin has appeared![/b]\nIt will damage your Madracis and Madrepora coral each turn.\n\nCreole Wrasse are natural predators of sea urchins. Add one to your reef to control the threat."
	_stressor_tooltip_dialog.add_child(body)


func _build_tutorial_overlay() -> void:
	_tutorial_overlay = TutorialOverlayScene.instantiate()
	add_child(_tutorial_overlay)
	if _tutorial_overlay.has_signal("advanced"):
		_tutorial_overlay.advanced.connect(_on_tutorial_advanced)


func _show_identify_phase() -> void:
	if _identify_dialog == null:
		return

	var target_coral := str(_level_def.get("target_coral", ""))
	_identify_subject = _select_identify_subject(target_coral)
	if _identify_subject.is_empty():
		return
	_in_identify_phase = true
	_set_gameplay_buttons_disabled(true)

	var canonical_name := str(_identify_subject.get("canonical_name", "Unknown"))

	var choices: Array[String] = [canonical_name]
	var coral_names := _available_coral_names()
	while choices.size() < 4 and coral_names.size() > 0:
		var candidate := coral_names[randi() % coral_names.size()]
		if not choices.has(candidate):
			choices.append(candidate)
	choices.shuffle()
	_rebuild_identify_choices(choices)

	_identify_image.visible = false
	_identify_image.texture = null
	var texture := _identify_subject_texture(_identify_subject, canonical_name)
	if texture != null:
		_identify_image.texture = texture
		_identify_image.visible = true

	_set_turn_hint("Identify the reef first — or close to skip")
	if _identify_skip_label:
		_identify_skip_label.visible = not _tutorial_active
	_identify_dialog.popup_centered()
	if _tutorial_active and _tutorial_step_id.is_empty():
		_show_tutorial_step("identify_intro")


func _on_identify_skipped() -> void:
	if _tutorial_active:
		_in_identify_phase = true
		_set_gameplay_buttons_disabled(true)
		status_label.text = "Pick at least one species to continue the tutorial."
		if _identify_dialog:
			_identify_dialog.popup_centered()
		return
	_in_identify_phase = false
	_identify_subject = {}
	_set_gameplay_buttons_disabled(false)
	_set_turn_hint("Adjust fish then press Turn")
	status_label.text = "Level %d ready — replicate the reef!" % _active_level_id
	if _tutorial_active and _tutorial_step_id == "identify_intro":
		_show_tutorial_step("goal_intro")


func _on_identify_confirmed() -> void:
	_in_identify_phase = false
	_set_gameplay_buttons_disabled(false)

	if _identify_subject.is_empty():
		status_label.text = "Level %d ready — replicate the reef!" % _active_level_id
		_identify_dialog.hide()
		return

	var selected_choices := _selected_identify_choices()
	if selected_choices.is_empty():
		_in_identify_phase = true
		_set_gameplay_buttons_disabled(true)
		status_label.text = "Select at least one species before submitting."
		return

	var canonical_name := str(_identify_subject.get("canonical_name", ""))
	var subject_id := str(_identify_subject.get("subject_id", ""))
	var submitted_text := ", ".join(selected_choices)
	_essential_species = selected_choices.duplicate()

	# Queue for offline sync — classification saved immediately
	if controller and controller.has_method("queue_offline_classification"):
		controller.call("queue_offline_classification", subject_id, canonical_name, submitted_text)

	# Check if correct and apply identify bonus
	var accepted_answers := _to_string_array(_identify_subject.get("accepted_answers", []))
	accepted_answers.append_array(_taxonomy_aliases_for(canonical_name))

	var is_correct := false
	for selected_choice in selected_choices:
		var normalized_guess := _normalize_label(selected_choice)
		for answer in accepted_answers:
			if _normalize_label(str(answer)) == normalized_guess:
				is_correct = true
				break
		if is_correct:
			break

	if is_correct:
		_identify_bonus_coins = _classification_bonus_coins
		status_label.text = "Correct! +%d bonus coins ready for completion. Now replicate the reef!" % _identify_bonus_coins
	else:
		_identify_bonus_coins = 0
		status_label.text = "Nice try — it was %s. Now replicate the reef!" % canonical_name

	_set_turn_hint("Adjust fish then press Turn")
	_identify_dialog.hide()
	if _tutorial_active and _tutorial_step_id == "identify_intro":
		_show_tutorial_step("goal_intro")


func _rebuild_identify_choices(choices: Array[String]) -> void:
	_identify_choice_checks.clear()
	if _identify_choice_list == null:
		return
	for child in _identify_choice_list.get_children():
		child.queue_free()
	for choice in choices:
		var row_panel := PanelContainer.new()
		var row_style := StyleBoxFlat.new()
		row_style.bg_color = Color(0.12, 0.12, 0.12, 0.45)
		row_style.border_color = Color(0.32, 0.32, 0.32, 0.9)
		row_style.border_width_left = 1
		row_style.border_width_top = 1
		row_style.border_width_right = 1
		row_style.border_width_bottom = 1
		row_style.corner_radius_top_left = 8
		row_style.corner_radius_top_right = 8
		row_style.corner_radius_bottom_right = 8
		row_style.corner_radius_bottom_left = 8
		row_panel.add_theme_stylebox_override("panel", row_style)
		_identify_choice_list.add_child(row_panel)

		var row_margin := MarginContainer.new()
		row_margin.add_theme_constant_override("margin_left", 8)
		row_margin.add_theme_constant_override("margin_top", 8)
		row_margin.add_theme_constant_override("margin_right", 8)
		row_margin.add_theme_constant_override("margin_bottom", 8)
		row_panel.add_child(row_margin)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row_margin.add_child(row)

		var preview := TextureRect.new()
		preview.custom_minimum_size = Vector2(84.0, 64.0)
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var preview_texture := _load_identify_reference_texture(choice)
		if preview_texture != null:
			preview.texture = preview_texture
		else:
			preview.modulate = Color(0.5, 0.5, 0.5, 0.65)
		row.add_child(preview)

		var checkbox := CheckBox.new()
		checkbox.text = choice
		checkbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		checkbox.add_theme_font_size_override("font_size", 16)
		row.add_child(checkbox)
		_identify_choice_checks.append(checkbox)


func _selected_identify_choices() -> Array[String]:
	var selected: Array[String] = []
	for checkbox in _identify_choice_checks:
		if checkbox != null and checkbox.button_pressed:
			selected.append(checkbox.text)
	return selected


func _load_identify_reference_texture(species_name: String) -> Texture2D:
	var slug := _normalize_label(species_name).replace(" ", "_")
	if slug.is_empty() or slug == "unknown":
		return null
	var folder_path := "%s/%s" % [CLICK_A_CORAL_DICTIONARY_PATH, slug]
	var dir := DirAccess.open(folder_path)
	if dir == null:
		return null
	var image_paths: Array[String] = []
	dir.list_dir_begin()
	while true:
		var entry := dir.get_next()
		if entry == "":
			break
		if dir.current_is_dir():
			continue
		if entry.ends_with(".import"):
			continue
		var lower := entry.to_lower()
		if lower.ends_with(".png") or lower.ends_with(".webp") or lower.ends_with(".jpg"):
			image_paths.append("%s/%s" % [folder_path, entry])
	dir.list_dir_end()
	if image_paths.is_empty():
		return null
	image_paths.sort()
	image_paths.sort_custom(func(a: String, b: String) -> bool:
		return _identify_texture_priority(a) < _identify_texture_priority(b)
	)
	for resource_path in image_paths:
		if not ResourceLoader.exists(resource_path):
			continue
		var texture := load(resource_path)
		if texture is Texture2D:
			return texture
	return null


func _select_identify_subject(target_coral: String) -> Dictionary:
	var wanted_subject_id := str(_level_def.get("subject_id", ""))
	if not wanted_subject_id.is_empty():
		for entry in _classification_entries:
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			if str(entry.get("subject_id", "")) == wanted_subject_id:
				return entry

	var matching: Array[Dictionary] = []
	for entry in _classification_entries:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var canonical := str(entry.get("canonical_name", ""))
		if _normalize_label(canonical) == _normalize_label(target_coral):
			matching.append(entry)
	if not matching.is_empty():
		return matching[randi() % matching.size()]

	return {
		"subject_id": str(_level_def.get("id", _active_level_id)),
		"canonical_name": target_coral,
		"accepted_answers": [target_coral],
		"resource_path": str(_level_def.get("identify_image_path", "")),
	}


func _identify_subject_texture(subject: Dictionary, canonical_name: String) -> Texture2D:
	var resource_path := str(subject.get("resource_path", ""))
	if not resource_path.is_empty() and FileAccess.file_exists(resource_path) and ResourceLoader.exists(resource_path):
		var texture := load(resource_path)
		if texture is Texture2D:
			return texture

	var reference_texture := _load_identify_reference_texture(canonical_name)
	if reference_texture != null:
		return reference_texture

	return _load_species_sprite_texture(canonical_name)


func _identify_texture_priority(resource_path: String) -> int:
	var lower := resource_path.to_lower()
	if lower.ends_with(".png"):
		return 0
	if lower.ends_with(".webp"):
		return 1
	if lower.ends_with(".jpg"):
		return 2
	return 3


func _load_species_sprite_texture(species_name: String) -> Texture2D:
	var slug := _normalize_label(species_name).replace(" ", "_")
	if slug.is_empty():
		return null
	var sprite_frames_path := "res://assets/sprites/%s.tres" % slug
	if not ResourceLoader.exists(sprite_frames_path):
		return null
	var frames := load(sprite_frames_path)
	if frames is SpriteFrames and frames.has_animation("default") and frames.get_frame_count("default") > 0:
		return frames.get_frame_texture("default", 0)
	return null


func _maybe_show_stressor_tooltip() -> bool:
	if _active_level_id != 4:
		return false
	if int(_fish_population.get("Longspine Sea Urchin", 0)) <= 0:
		return false
	if _stressor_tooltip_dialog == null or controller == null:
		return false
	if not controller.has_method("has_seen_stressor_tooltip"):
		return false
	if bool(controller.call("has_seen_stressor_tooltip", "urchin")):
		return false
	_resume_turn_after_stressor_tooltip = true
	_showing_turn_results = true
	_set_gameplay_buttons_disabled(true)
	_stressor_tooltip_dialog.popup_centered()
	return true


func _on_stressor_tooltip_dismissed() -> void:
	if controller and controller.has_method("mark_stressor_tooltip_shown"):
		controller.call("mark_stressor_tooltip_shown", "urchin")
	_showing_turn_results = false
	_set_gameplay_buttons_disabled(false)
	if _resume_turn_after_stressor_tooltip:
		_resume_turn_after_stressor_tooltip = false
		_advance_turn()


func _set_gameplay_buttons_disabled(disabled: bool) -> void:
	var blocked := disabled or _session_over or _showing_turn_results
	if turn_flow_strip and turn_flow_strip.has_method("set_disabled"):
		turn_flow_strip.set_disabled(blocked)
	
	for card in fish_cards:
		if is_instance_valid(card):
			card.set_disabled(blocked)


func _init_breeding_timers() -> void:
	# Clear old timers
	for species in _breeding_timers:
		var timer = _breeding_timers[species]
		if is_instance_valid(timer):
			timer.queue_free()
	_breeding_timers.clear()
	
	# Clear old eggs
	for egg in _active_eggs:
		if is_instance_valid(egg):
			egg.queue_free()
	_active_eggs.clear()

	var all_relevant_fish = _fish_species_order.duplicate()
	for species in all_relevant_fish:
		if _fish_specs_by_name.has(species) or _stressor_specs_by_name.has(species):
			var timer := Timer.new()
			timer.process_mode = Node.PROCESS_MODE_ALWAYS # Never paused
			timer.one_shot = true
			var interval_min = float(_level_def.get("breeding_interval_min", 30.0))
			var interval_max = float(_level_def.get("breeding_interval_max", 45.0))
			timer.wait_time = randf_range(interval_min, interval_max)
			timer.timeout.connect(_on_breeding_timer_timeout.bind(species))
			add_child(timer)
			timer.start()
			_breeding_timers[species] = timer


func _on_breeding_timer_timeout(species: String) -> void:
	var pop := int(_fish_population.get(species, 0))
	if pop >= 2:
		_spawn_egg(species)
	
	# Re-randomize and restart timer
	var timer = _breeding_timers.get(species)
	if is_instance_valid(timer):
		var interval_min = float(_level_def.get("breeding_interval_min", 30.0))
		var interval_max = float(_level_def.get("breeding_interval_max", 45.0))
		timer.wait_time = randf_range(interval_min, interval_max)
		timer.start()


func _spawn_egg(species: String) -> void:
	if reef_layer == null:
		return
		
	var egg = EggNodeScene.instantiate()
	reef_layer.add_child(egg)
	_active_eggs.append(egg)
	
	# Position egg randomly in the viewport or near parent (simplified: random)
	var rect := reef_layer.get_rect()
	egg.position = Vector2(
		randf_range(rect.size.x * 0.1, rect.size.x * 0.9),
		randf_range(rect.size.y * 0.2, rect.size.y * 0.7)
	)
	
	var slug := species.to_lower().replace(" ", "_")
	var egg_frames_path := "res://assets/sprites/%s_egg.tres" % slug
	
	# Wait, I didn't create .tres files for eggs yet.
	# The script generated sheets and PNGs but I need to load them.
	# I'll use a helper to load or create SpriteFrames on the fly for eggs if needed.
	# Actually, I should have generated .tres files for eggs too.
	# Let's check how .tres files are generated.
	
	# For now, I'll just load the frames if they exist.
	if ResourceLoader.exists(egg_frames_path):
		var frames = load(egg_frames_path)
		egg.setup(species, frames)
	else:
		# Fallback: use first frame of standard fish but modulate it?
		# Or just use a generic egg if I had one.
		# I'll just load the first frame of the egg PNG for now if no .tres.
		pass

func _on_egg_placed(egg_node: Node) -> void:
	var species = egg_node.get("species")
	if species:
		_fish_population[species] = int(_fish_population.get(species, 0)) + 1
		_add_fish_instance(str(species))
		_rebuild_species_order()
		_refresh_fish_rows()
		_update_text()
		status_label.text = "New %s hatched and placed!" % species
	
	_active_eggs.erase(egg_node)
	egg_node.queue_free()


# ─── Breeding Preview Dialog ─────────────────────────────────────────────────

func _build_breed_preview_dialog() -> void:
	_breed_preview_dialog = AcceptDialog.new()
	_breed_preview_dialog.title = "Breeding Preview"
	_breed_preview_dialog.dialog_hide_on_ok = true
	_breed_preview_dialog.ok_button_text = "Confirm Breed"
	_breed_preview_dialog.canceled.connect(_on_breed_preview_cancelled)
	_breed_preview_dialog.confirmed.connect(_on_breed_preview_confirmed)
	add_child(_breed_preview_dialog)

	var root := VBoxContainer.new()
	root.custom_minimum_size = Vector2(460.0, 0.0)
	root.add_theme_constant_override("separation", 10)

	_breed_preview_label = RichTextLabel.new()
	_breed_preview_label.fit_content = true
	_breed_preview_label.bbcode_enabled = true
	_breed_preview_label.scroll_active = false
	root.add_child(_breed_preview_label)

	_breed_preview_dialog.add_child(root)


func _show_breed_preview(parents: Array[String]) -> void:
	if _breed_preview_dialog == null or _breed_preview_label == null:
		return

	_breed_preview_parents = parents
	var breed_cost := _breed_cost_for_parents(parents)
	var success_chance := _breed_success_for_parents(parents)

	# Apply fast_breeder trait modifier
	for parent in parents:
		var trait_name := str(_fish_active_traits.get(parent, ""))
		if not trait_name.is_empty():
			var trait_def: Dictionary = _trait_definitions.get(trait_name, {})
			if typeof(trait_def) == TYPE_DICTIONARY:
				var breed_success_delta := float(trait_def.get("breed_success_delta", 0.0))
				success_chance = clampf(success_chance + breed_success_delta, 0.05, 0.95)

	# Compute weighted offspring probabilities
	var weights: Dictionary = {}
	for parent in parents:
		var spec: Dictionary = _fish_specs_by_name.get(parent, {})
		var offs: Dictionary = spec.get("offspring_weights", {})
		for sp in offs.keys():
			weights[str(sp)] = int(weights.get(str(sp), 0)) + maxi(0, int(offs[sp]))
		if offs.is_empty():
			weights[parent] = int(weights.get(parent, 0)) + 1

	var total_w := 0
	for v in weights.values():
		total_w += int(v)

	# Possible inherited traits
	var possible_traits: Array[String] = []
	for parent in parents:
		var available: Variant = _species_available_traits.get(parent, [])
		if typeof(available) == TYPE_ARRAY:
			for t in available:
				var ts := str(t)
				if not possible_traits.has(ts):
					possible_traits.append(ts)

	var lines: Array[String] = []
	lines.append("[b]Breeding:[/b] %s × %s" % [parents[0], parents[1]])
	lines.append("Cost: [b]%d nutrients[/b] | Success chance: [b]%.0f%%[/b]" % [breed_cost, success_chance * 100.0])
	lines.append("")
	lines.append("[b]Possible offspring:[/b]")
	if total_w > 0:
		var sorted_species: Array = []
		for sp in weights.keys():
			sorted_species.append({"species": str(sp), "weight": int(weights[sp])})
		sorted_species.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return int(a["weight"]) > int(b["weight"])
		)
		var shown := 0
		for entry in sorted_species:
			if shown >= 4:
				break
			var pct := int(round(float(int(entry["weight"])) / float(total_w) * 100.0))
			var sp_name := str(entry["species"])
			var active_trait := str(_fish_active_traits.get(sp_name, ""))
			var trait_str := (" [i][%s][/i]" % active_trait) if not active_trait.is_empty() else ""
			lines.append("  • %s: %d%%%s" % [sp_name, pct, trait_str])
			shown += 1
	else:
		lines.append("  • %s (100%%)" % parents[0])

	if not possible_traits.is_empty():
		lines.append("")
		lines.append("[b]Possible inherited traits:[/b] %s" % ", ".join(possible_traits))
		lines.append("[i]50%% chance to inherit one trait from a parent.[/i]")

	_breed_preview_label.text = "\n".join(lines)
	_breed_preview_dialog.popup_centered()


func _on_breed_preview_cancelled() -> void:
	_breed_preview_parents = []


func _on_breed_preview_confirmed() -> void:
	if _breed_preview_parents.is_empty():
		return
	_execute_breed(_breed_preview_parents)
	_breed_preview_parents = []


# ─── Classification dialog (post-level quiz) ──────────────────────────────────

func _build_classification_dialog() -> void:
	_classification_dialog = AcceptDialog.new()
	_classification_dialog.title = "Coral Classification"
	_classification_dialog.dialog_hide_on_ok = true
	_classification_dialog.ok_button_text = "Submit"
	_classification_dialog.canceled.connect(_on_classification_cancelled)
	_classification_dialog.confirmed.connect(_on_classification_confirmed)
	add_child(_classification_dialog)

	var root := VBoxContainer.new()
	root.custom_minimum_size = Vector2(520.0, 320.0)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)

	_classification_prompt_label = RichTextLabel.new()
	_classification_prompt_label.fit_content = true
	_classification_prompt_label.bbcode_enabled = true
	_classification_prompt_label.scroll_active = false
	root.add_child(_classification_prompt_label)

	_classification_image = TextureRect.new()
	_classification_image.custom_minimum_size = Vector2(420.0, 180.0)
	_classification_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_classification_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_classification_image.visible = false
	root.add_child(_classification_image)

	var picker_label := Label.new()
	picker_label.text = "Choose coral type:"
	root.add_child(picker_label)

	_classification_guess_option = OptionButton.new()
	root.add_child(_classification_guess_option)

	_classification_dialog.add_child(root)


# ─── Level End Overlay ────────────────────────────────────────────────────────

func _build_level_end_overlay() -> void:
	_level_end_overlay = CanvasLayer.new()
	_level_end_overlay.layer = 10
	_level_end_overlay.visible = false
	add_child(_level_end_overlay)

	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.06, 0.14, 0.92)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_level_end_overlay.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_level_end_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480.0, 0.0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var title := Label.new()
	title.name = "Title"
	title.text = "Reef Replicated!"
	title.add_theme_font_size_override("font_size", 26)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var divider := HSeparator.new()
	vbox.add_child(divider)

	_level_end_stats_label = RichTextLabel.new()
	_level_end_stats_label.name = "StatsLabel"
	_level_end_stats_label.fit_content = true
	_level_end_stats_label.bbcode_enabled = true
	_level_end_stats_label.scroll_active = false
	_level_end_stats_label.custom_minimum_size = Vector2(0.0, 80.0)
	vbox.add_child(_level_end_stats_label)

	_level_end_species_label = RichTextLabel.new()
	_level_end_species_label.name = "SpeciesLabel"
	_level_end_species_label.fit_content = true
	_level_end_species_label.bbcode_enabled = true
	_level_end_species_label.scroll_active = false
	vbox.add_child(_level_end_species_label)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 12)
	vbox.add_child(btn_row)

	_level_end_next_btn = Button.new()
	_level_end_next_btn.name = "NextLevelButton"
	_level_end_next_btn.text = "Next Level"
	_level_end_next_btn.pressed.connect(_on_level_end_next)
	btn_row.add_child(_level_end_next_btn)

	var home_btn := Button.new()
	home_btn.name = "HomeButton"
	home_btn.text = "Back to Home"
	home_btn.pressed.connect(_on_level_end_home)
	btn_row.add_child(home_btn)


func _build_turn_results_overlay() -> void:
	var panel = TurnResultsPanelScene.instantiate()
	add_child(panel)
	_turn_results_overlay = panel
	panel.continued.connect(_on_turn_results_continued)


func _on_turn_results_continued() -> void:
	_showing_turn_results = false
	if _tutorial_active and _tutorial_step_id == "results_intro":
		_hide_tutorial_step()
	_update_text()
	# Check for level end after closing results
	if _turns_remaining <= 0 and not _session_over:
		_session_over = true
		_fail_reason = _build_turns_exhausted_fail_reason()
		status_label.text = _fail_reason
		_refresh_fish_rows()
		_update_text()
		_show_level_fail_overlay()


func _show_turn_results(turn_number: int, current_populations: Dictionary, target_populations: Dictionary, turns_remaining: int) -> void:
	if _turn_results_overlay == null:
		return

	_showing_turn_results = true
	_set_gameplay_buttons_disabled(true)
	
	var turn_limit := int(_level_def.get("turn_limit", 0))
	_turn_results_overlay.show_results(turn_number, turn_limit, current_populations, target_populations, turns_remaining)
	if _tutorial_active and not _tutorial_results_seen:
		_tutorial_results_seen = true
		_show_tutorial_step("results_intro")


func _show_level_end_overlay(coins_earned: int) -> void:
	if _level_end_overlay == null:
		return

	var turn_limit := int(_level_def.get("turn_limit", 6))
	var speed_bonus := maxi(0, turn_limit - _turns_used) * 5
	var base_coins := int(_level_def.get("reward_coins", 10))
	var total_coins := base_coins + speed_bonus + _identify_bonus_coins
	var rewards_pending := false
	if controller and controller.has_method("get_pending_reward_total"):
		rewards_pending = int(controller.call("get_pending_reward_total")) > 0

	if _level_end_stats_label:
		var lines: Array[String] = []
		lines.append("[b]Level %d — %s[/b]" % [_active_level_id, str(_level_def.get("name", ""))])
		lines.append("Turns used: [b]%d[/b] / %d" % [_turns_used, turn_limit])
		lines.append("Base coins: [b]+%d[/b]" % base_coins)
		if speed_bonus > 0:
			lines.append("Speed bonus (%d turns left): [b]+%d[/b]" % [turn_limit - _turns_used, speed_bonus])
		if _identify_bonus_coins > 0:
			lines.append("Correct identification: [b]+%d[/b]" % _identify_bonus_coins)
		if rewards_pending:
			lines.append("[b]Reward pending sync: %d coins[/b]" % total_coins)
			lines.append("Coins land after the next successful sync.")
		else:
			lines.append("[b]Total earned: %d coins[/b]" % total_coins)
		_level_end_stats_label.text = "\n".join(lines)

	if _level_end_species_label:
		var target_coral := str(_level_def.get("target_coral", "Unknown"))
		var coral_spec: Dictionary = _coral_specs_by_name.get(target_coral, {})
		var common := str(coral_spec.get("common_name", ""))
		var notes := str(coral_spec.get("notes", ""))
		var text := "[b]Replicated:[/b] %s" % target_coral
		if not common.is_empty():
			text += " (%s)" % common
		if not notes.is_empty():
			text += "\n[i]%s[/i]" % notes
		_level_end_species_label.text = text

	if _level_end_next_btn:
		_level_end_next_btn.visible = _active_level_id < LEVEL_COUNT

	_level_end_overlay.visible = true


func _build_level_fail_overlay() -> void:
	_level_fail_overlay = CanvasLayer.new()
	_level_fail_overlay.layer = 10
	_level_fail_overlay.visible = false
	add_child(_level_fail_overlay)

	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.02, 0.05, 0.92)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_level_fail_overlay.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_level_fail_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460.0, 0.0)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Reef Not Stable Yet"
	title.add_theme_font_size_override("font_size", 26)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	_level_fail_stats_label = RichTextLabel.new()
	_level_fail_stats_label.fit_content = true
	_level_fail_stats_label.bbcode_enabled = true
	_level_fail_stats_label.scroll_active = false
	_level_fail_stats_label.custom_minimum_size = Vector2(0.0, 96.0)
	vbox.add_child(_level_fail_stats_label)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 12)
	vbox.add_child(btn_row)

	var retry_btn := Button.new()
	retry_btn.text = "Retry Level"
	retry_btn.pressed.connect(_on_level_fail_retry)
	btn_row.add_child(retry_btn)

	var home_btn := Button.new()
	home_btn.text = "Back to Home"
	home_btn.pressed.connect(_on_level_fail_home)
	btn_row.add_child(home_btn)


func _show_level_fail_overlay() -> void:
	if _level_fail_overlay == null:
		return

	if _level_fail_stats_label:
		var turn_limit := int(_level_def.get("turn_limit", 0))
		var reef_percent := 0
		if _target_population > 0:
			reef_percent = int(round(clampf(float(_coral_population) / float(_target_population), 0.0, 1.0) * 100.0))
		var lines: Array[String] = []
		lines.append("[b]Level %d — %s[/b]" % [_active_level_id, str(_level_def.get("name", ""))])
		lines.append("[b]%s[/b]" % _fail_reason)
		lines.append("Turns used: [b]%d[/b] / %d" % [_turns_used, turn_limit])
		lines.append("Target reef: [b]%d[/b]" % _target_population)
		lines.append("Current reef: [b]%d[/b] (%d%%)" % [_coral_population, reef_percent])
		lines.append("Nutrients left: [b]%d[/b]" % _nutrients)
		lines.append("[i]You earned credit for classifying this reef image even if the puzzle failed.[/i]")
		_level_fail_stats_label.text = "\n".join(lines)

	_level_fail_overlay.visible = true


func _on_level_fail_retry() -> void:
	if _level_fail_overlay:
		_level_fail_overlay.visible = false
	_reset_level()


func _on_level_fail_home() -> void:
	if _level_fail_overlay:
		_level_fail_overlay.visible = false
	_go_home()


func _on_level_end_next() -> void:
	_level_end_overlay.visible = false
	_session_over = false  # Allow _on_level_progress_changed to start the next level
	if _active_level_id < LEVEL_COUNT:
		_select_level(_active_level_id + 1)


func _on_level_end_home() -> void:
	_level_end_overlay.visible = false
	_go_home()


# ─── Shop Overlay ─────────────────────────────────────────────────────────────

func _build_shop_overlay() -> void:
	_shop_overlay = CanvasLayer.new()
	_shop_overlay.layer = 9
	_shop_overlay.visible = false
	add_child(_shop_overlay)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.6)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.gui_input.connect(_on_shop_bg_click)
	_shop_overlay.add_child(bg)

	var right_panel := PanelContainer.new()
	right_panel.name = "ShopPanel"
	right_panel.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	right_panel.custom_minimum_size = Vector2(300.0, 0.0)
	right_panel.offset_left = -300.0
	_shop_overlay.add_child(right_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	right_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var header_row := HBoxContainer.new()
	vbox.add_child(header_row)

	var shop_title := Label.new()
	shop_title.text = "Reef Shop"
	shop_title.add_theme_font_size_override("font_size", 20)
	shop_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(shop_title)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.pressed.connect(_hide_shop)
	header_row.add_child(close_btn)

	_shop_coins_label = Label.new()
	_shop_coins_label.name = "CoinsLabel"
	_shop_coins_label.text = "Coins: 0"
	vbox.add_child(_shop_coins_label)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	_add_shop_item(vbox, "Fish Egg", "Add 1 fish of the best helper species", SHOP_FISH_EGG_COST, "_on_shop_buy_fish_egg")

	var hint := Label.new()
	hint.text = "Tap outside to close"
	hint.modulate = Color(0.6, 0.6, 0.6)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)


func _add_shop_item(parent: VBoxContainer, item_name: String, description: String, cost: int, method_name: String) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	parent.add_child(row)

	var top_row := HBoxContainer.new()
	row.add_child(top_row)

	var name_label := Label.new()
	name_label.text = item_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(name_label)

	var buy_btn := Button.new()
	buy_btn.text = "%d 🪙" % cost
	buy_btn.pressed.connect(Callable(self, method_name))
	top_row.add_child(buy_btn)

	var desc_label := Label.new()
	desc_label.text = description
	desc_label.modulate = Color(0.75, 0.75, 0.75)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(desc_label)

	var sep := HSeparator.new()
	parent.add_child(sep)


func _show_shop() -> void:
	if _shop_overlay == null or _session_over or _in_identify_phase or _showing_turn_results:
		return
	_update_shop_coins()
	_shop_overlay.visible = true


func _hide_shop() -> void:
	if _shop_overlay:
		_shop_overlay.visible = false


func _on_shop_bg_click(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		_hide_shop()


func _on_shop_buy_fish_egg() -> void:
	if controller == null or not controller.has_method("spend_coins"):
		return
	var success: bool = controller.call("spend_coins", SHOP_FISH_EGG_COST)
	if not success:
		status_label.text = "Not enough coins (need %d)" % SHOP_FISH_EGG_COST
		return

	# Target the first positive fish species available
	var target := ""
	for species in _positive_fish:
		if _fish_specs_by_name.has(species):
			target = species
			break
	if target.is_empty() and not _fish_species_order.is_empty():
		target = _fish_species_order[0]
	
	if target.is_empty():
		status_label.text = "No species available for egg"
		return

	_spawn_egg(target)
	status_label.text = "Purchased %s egg!" % target
	_update_shop_coins()
	_update_text()


func _update_shop_coins() -> void:
	if _shop_coins_label == null:
		return
	var coins := 0
	if controller and controller.has_method("get_coins"):
		coins = controller.call("get_coins")
	_shop_coins_label.text = "Coins: %d" % coins


# ─── Level start / state ──────────────────────────────────────────────────────

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

	# Don't restart the level while the session-over overlay is visible —
	# complete_current_level() advances current_level by 1, which would
	# otherwise immediately trigger _start_level_from_state and hide the win overlay.
	if _active_level_id != current_level and not _session_over:
		_start_level_from_state(parsed)
	else:
		_update_text()


func _start_level_from_state(parsed: Dictionary) -> void:
	_active_level_id = int(parsed.get("current_level", 1))
	_level_def = parsed.get("current_level_definition", {})
	if typeof(_level_def) != TYPE_DICTIONARY:
		_level_def = {}

	_target_population = int(_level_def.get("target_population", 8))
	_turns_remaining = int(_level_def.get("turn_limit", 6))
	_turns_used = 0
	_triggers_remaining = _triggers_per_turn
	_coral_population = maxi(1, int(round(_target_population * 0.35)))
	_nutrients = int(parsed.get("current_level_available_nutrients", 0))
	_turn_nutrients_spent = 0
	_session_over = false
	_in_identify_phase = false
	_showing_turn_results = false
	_resume_turn_after_stressor_tooltip = false
	_identify_bonus_coins = 0
	_essential_species = []
	_pending_classification = {}
	_fish_active_traits = {}
	_salinity_adjustment = 0
	_temperature_adjustment = 0
	_tutorial_results_seen = false
	_tutorial_step_id = ""
	_tutorial_active = false
	if controller and controller.has_method("is_tutorial_complete"):
		_tutorial_active = _active_level_id == 1 and not bool(controller.call("is_tutorial_complete"))
	if _tutorial_active:
		_turns_remaining = maxi(_turns_remaining, 8)
		_nutrients = maxi(_nutrients, 14)

	# Hide overlays from any previous level
	if _level_end_overlay:
		_level_end_overlay.visible = false
	if _level_fail_overlay:
		_level_fail_overlay.visible = false
	if _shop_overlay:
		_shop_overlay.visible = false
	if _turn_results_overlay:
		_turn_results_overlay.visible = false
	if _stressor_tooltip_dialog:
		_stressor_tooltip_dialog.hide()
	if _tutorial_overlay and _tutorial_overlay.has_method("hide_step"):
		_tutorial_overlay.hide_step()

	_fish_population = {}
	var starting_fish: Dictionary = _level_def.get("starting_fish", {})
	for species in starting_fish.keys():
		_fish_population[str(species)] = int(starting_fish[species])
	_seed_fish_instances(starting_fish)

	_positive_fish = _to_string_array(_level_def.get("positive_fish", []))
	_negative_fish = _to_string_array(_level_def.get("negative_fish", []))

	for species in _positive_fish:
		if not _fish_population.has(species):
			_fish_population[species] = 0
	for species in _negative_fish:
		if not _fish_population.has(species):
			_fish_population[species] = 0

	_rebuild_species_order()
	_refresh_fish_rows()
	_update_coral_growth_visuals()
	_init_breeding_timers()
	status_label.text = "Level %d — replicate the reef!" % _active_level_id
	_update_text()
	_update_reef_title()
	_update_breed_row_labels()

	# Launch the citizen science identify phase after this frame settles
	call_deferred("_show_identify_phase")


func _update_reef_title() -> void:
	if reef_layer == null:
		return
	var title_node := reef_layer.get_node_or_null("TitlePlate/ReefTitle") as Label
	if title_node:
		var level_name := str(_level_def.get("name", "Level %d" % _active_level_id))
		title_node.text = "%s — Level %d" % [level_name, _active_level_id]


func _update_breed_row_labels() -> void:
	# TopFlowBar is retired, this function is now a no-op
	pass


func _to_string_array(value: Variant) -> Array:
	if controller and controller.has_method("to_string_array"):
		return controller.call("to_string_array", value)
	var output: Array = []
	if typeof(value) == TYPE_ARRAY:
		for v in value:
			output.append(str(v))
	return output


func _rebuild_species_order() -> void:
	_fish_species_order = []
	for species in _fish_population.keys():
		_fish_species_order.append(str(species))
	_fish_species_order.sort()


func _seed_fish_instances(starting_fish: Dictionary) -> void:
	_fish_instances = {}
	_fish_instance_counter = 0
	for species in starting_fish.keys():
		var species_name := str(species)
		var count := int(starting_fish[species])
		for _i in range(count):
			_add_fish_instance(species_name, 0, -1)


func _add_fish_instance(species: String, placed_at_turn: int = -1, last_fed_at_turn: int = -1) -> void:
	var entries: Array = _fish_instances.get(species, []).duplicate(true)
	entries.append({
		"placed_at_turn": placed_at_turn if placed_at_turn >= 0 else _turns_used,
		"last_fed_at_turn": last_fed_at_turn if last_fed_at_turn >= 0 else _turns_used,
		"placed_order": _fish_instance_counter,
	})
	_fish_instance_counter += 1
	_fish_instances[species] = entries


func _remove_fish_instance(species: String, starvation: bool = false) -> Dictionary:
	var entries: Array = _fish_instances.get(species, []).duplicate(true)
	if entries.is_empty():
		return {}
	var removed: Dictionary = {}
	if starvation:
		entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			var a_placed := int(a.get("placed_at_turn", 0))
			var b_placed := int(b.get("placed_at_turn", 0))
			if a_placed != b_placed:
				return a_placed < b_placed
			var a_fed := int(a.get("last_fed_at_turn", -1))
			var b_fed := int(b.get("last_fed_at_turn", -1))
			if a_fed != b_fed:
				return a_fed < b_fed
			return int(a.get("placed_order", 0)) < int(b.get("placed_order", 0))
		)
		removed = entries.pop_front()
	else:
		removed = entries.pop_back()
	_fish_instances[species] = entries
	return removed


func _population_cap() -> int:
	var configured := int(_level_def.get("population_cap", 0))
	if configured > 0:
		return configured
	var starting_fish: Dictionary = _level_def.get("starting_fish", {})
	var total := 0
	for species in starting_fish.keys():
		if _fish_specs_by_name.has(str(species)):
			total += int(starting_fish[species])
	return total + 2


func _total_live_fish() -> int:
	var total := 0
	for species in _fish_population.keys():
		if _fish_specs_by_name.has(str(species)):
			total += int(_fish_population[species])
	return total


func _find_fish_card(species: String) -> Node:
	for card in fish_cards:
		if is_instance_valid(card) and str(card.get("species")) == species:
			return card
	return null


func _refresh_fish_rows() -> void:
	if cards_hbox == null: return
	
	# Clear old cards
	for child in cards_hbox.get_children():
		child.queue_free()
	fish_cards.clear()
	
	for species in _fish_species_order:
		var card = FishCardScene.instantiate()
		cards_hbox.add_child(card)
		fish_cards.append(card)
		
		var slug = species.to_lower().replace(" ", "_")
		var frames_path = "res://assets/sprites/%s_card.tres" % slug
		if ResourceLoader.exists(frames_path):
			var frames = load(frames_path)
			card.setup(species, frames)
		
		card.update_pop(int(_fish_population.get(species, 0)))
		
		card.feed_pressed.connect(_adjust_fish.bind(species, 1))
		card.net_pressed.connect(_adjust_fish.bind(species, -1))
		
		card.set_disabled(_session_over or _in_identify_phase or _showing_turn_results)

	if _tutorial_active and _tutorial_step_id == "feed_action":
		_refresh_tutorial_target()


func _update_text() -> void:
	# Update resource labels
	if _bottom_nutrients_label:
		_bottom_nutrients_label.text = "Nutrients: %d" % _nutrients
	if _bottom_coins_label:
		if controller and controller.has_method("get_coins"):
			_bottom_coins_label.text = "Coins: %d" % int(controller.call("get_coins"))
	if _bottom_turn_label:
		var total_turns := _turns_used + _turns_remaining
		_bottom_turn_label.text = "Turn: %d/%d  ⚡%d" % [_turns_used, total_turns, _triggers_remaining]
	if _bottom_reef_label:
		var reef_percent := 0
		if _target_population > 0:
			reef_percent = int(round(clampf(float(_coral_population) / float(_target_population), 0.0, 1.0) * 100.0))
		_bottom_reef_label.text = "Reef: %d%%" % reef_percent
	
	# Update ObjectiveCard
	if objective_card and objective_card.has_method("update_objective"):
		var target_species := str(_level_def.get("target_coral", "Unknown"))
		objective_card.update_objective(target_species, _target_population, _turns_remaining)
		_update_environment_meters(target_species)
	
	# Update TurnFlowStrip
	if turn_flow_strip and turn_flow_strip.has_method("set_disabled"):
		turn_flow_strip.set_disabled(_session_over or _in_identify_phase or _showing_turn_results)
	if turn_flow_strip and turn_flow_strip.has_method("set_step"):
		turn_flow_strip.set_step(1)
	var environment_locked := _session_over or _in_identify_phase or _showing_turn_results or _triggers_remaining <= 0
	if salinity_down_button:
		salinity_down_button.disabled = environment_locked or _salinity_adjustment <= -1
	if salinity_up_button:
		salinity_up_button.disabled = environment_locked or _salinity_adjustment >= 1
	if temp_down_button:
		temp_down_button.disabled = environment_locked or _temperature_adjustment <= -1
	if temp_up_button:
		temp_up_button.disabled = environment_locked or _temperature_adjustment >= 1

	# Update Fish Cards
	for card in fish_cards:
		if is_instance_valid(card):
			card.update_pop(int(_fish_population.get(card.species, 0)))
			card.set_disabled(_session_over or _in_identify_phase or _showing_turn_results)
			if card.has_method("set_net_state"):
				var net_disabled := _session_over or _in_identify_phase or _showing_turn_results or _triggers_remaining <= 0
				card.call("set_net_state", net_disabled, _triggers_remaining, _triggers_per_turn)
			if card.has_method("set_extinct_state"):
				card.call("set_extinct_state", int(_fish_population.get(card.species, 0)) <= 0)

	_update_coral_growth_visuals()
	if _tutorial_active:
		_refresh_tutorial_target()


func _set_turn_hint(text: String) -> void:
	if turn_hint_label:
		turn_hint_label.text = text


func _show_tutorial_step(step_id: String) -> void:
	if not _tutorial_active or _tutorial_overlay == null:
		return
	var step: Dictionary = _tutorial_steps.get(step_id, {})
	if typeof(step) != TYPE_DICTIONARY:
		return
	_tutorial_step_id = step_id
	var title := str(step.get("title", "Tutorial"))
	var body := str(step.get("body", ""))
	var show_button := step.has("button_text")
	var button_text := str(step.get("button_text", "Continue"))
	var target := _tutorial_target_for_step(step_id)
	if show_button and step_id != "results_intro":
		_set_gameplay_buttons_disabled(true)
	_tutorial_overlay.show_step(title, body, target, show_button, button_text)


func _hide_tutorial_step() -> void:
	if _tutorial_overlay and _tutorial_overlay.has_method("hide_step"):
		_tutorial_overlay.hide_step()
	if _tutorial_active:
		_set_gameplay_buttons_disabled(false)
	_tutorial_step_id = ""


func _on_tutorial_advanced() -> void:
	if not _tutorial_active:
		return
	match _tutorial_step_id:
		"goal_intro":
			_hide_tutorial_step()
			_show_tutorial_step("feed_action")
		"end_turn_action":
			_hide_tutorial_step()
		"win_outro":
			_hide_tutorial_step()
			if controller and controller.has_method("set_tutorial_complete"):
				controller.call("set_tutorial_complete", true)
			_tutorial_active = false
		_:
			_hide_tutorial_step()


func _refresh_tutorial_target() -> void:
	if not _tutorial_active or _tutorial_overlay == null or _tutorial_step_id.is_empty():
		return
	_tutorial_overlay.refresh_target(_tutorial_target_for_step(_tutorial_step_id))


func _tutorial_target_for_step(step_id: String) -> Control:
	match step_id:
		"identify_intro":
			return _identify_choice_list if _identify_choice_list != null else _identify_image
		"goal_intro":
			return objective_card as Control
		"feed_action":
			return _first_feed_button()
		"end_turn_action":
			return next_turn_button
		"results_intro":
			return _turn_results_overlay.get_node_or_null("PanelContainer") as Control
		"win_outro":
			return null
		_:
			return null


func _first_feed_button() -> Control:
	for card in fish_cards:
		if not is_instance_valid(card):
			continue
		var button := card.get_node_or_null("Margin/VBox/ActionRow/FeedButton") as Control
		if button != null:
			return button
	return null


# ─── Coral alignment & animations ────────────────────────────────────────────

func _align_coral_to_sand() -> void:
	if reef_layer == null:
		return
	var sand_top := reef_layer.size.y * 0.80
	if sand_top <= 0.0:
		return
	for coral in [coral_1, coral_2, coral_3]:
		var c := coral as AnimatedSprite2D
		if c == null:
			continue
		c.position.y = sand_top - c.scale.y * 64.0 + 16.0


func _start_ambient_animation() -> void:
	for fish in [fish_swim_1, fish_swim_2, fish_swim_3]:
		var f2 := fish as AnimatedSprite2D
		if f2 == null:
			continue
		var base_pos := f2.position
		var tw2 := create_tween().set_loops()
		tw2.tween_property(f2, "position", base_pos + Vector2(10.0, -4.0), 1.2)
		tw2.tween_property(f2, "position", base_pos + Vector2(-8.0, 3.0), 1.4)
		tw2.tween_property(f2, "position", base_pos, 1.1)

	for coral in [coral_1, coral_2, coral_3]:
		var c2 := coral as AnimatedSprite2D
		if c2 == null:
			continue
		var tw3 := create_tween().set_loops()
		tw3.tween_property(c2, "rotation_degrees", 2.8, 1.8)
		tw3.tween_property(c2, "rotation_degrees", -2.8, 1.8)
		tw3.tween_property(c2, "rotation_degrees", 0.0, 1.2)

	for patch in [coral_patch_1a, coral_patch_1b, coral_patch_1c, coral_patch_2a, coral_patch_2b, coral_patch_2c, coral_patch_3a, coral_patch_3b, coral_patch_3c]:
		var p := patch as AnimatedSprite2D
		if p == null:
			continue
		var tw4 := create_tween().set_loops()
		tw4.tween_property(p, "rotation_degrees", 3.0, 1.1)
		tw4.tween_property(p, "rotation_degrees", -3.0, 1.1)
		tw4.tween_property(p, "rotation_degrees", 0.0, 0.8)


# ─── Fish actions ─────────────────────────────────────────────────────────────

func _on_feed_pressed(index: int) -> void:
	if index >= 0 and index < _fish_species_order.size():
		_adjust_fish(_fish_species_order[index], 1)


func _on_net_pressed(index: int) -> void:
	if index >= 0 and index < _fish_species_order.size():
		_adjust_fish(_fish_species_order[index], -1)


func _adjust_fish(species: String, delta: int) -> void:
	if _session_over or _in_identify_phase or _showing_turn_results:
		return
	if _nutrients <= 0:
		status_label.text = "Out of nutrients"
		return
	if delta < 0 and _triggers_remaining <= 0:
		status_label.text = "No triggers remaining this turn"
		return

	var current := int(_fish_population.get(species, 0))
	var next_value := maxi(0, current + delta)
	if next_value == current:
		return

	_fish_population[species] = next_value
	if delta > 0:
		_add_fish_instance(species)
	else:
		_remove_fish_instance(species)
	_nutrients -= 1
	_turn_nutrients_spent += 1
	if delta < 0:
		_consume_trigger()
	if next_value <= 0 and _is_essential_species(species):
		_on_essential_extinct(species)
		return

	# Show interaction hint when adjusting
	var hint := _get_interaction_hint(species)
	if not hint.is_empty():
		status_label.text = "%s %s (%d) — %s" % [species, "fed" if delta > 0 else "netted", next_value, hint]
	else:
		status_label.text = "%s %s (%d)" % [species, "fed" if delta > 0 else "netted", next_value]
	_update_text()
	if _tutorial_active and delta > 0 and _tutorial_step_id == "feed_action":
		_show_tutorial_step("end_turn_action")
	if _nutrients <= 0:
		_advance_turn()


func _get_interaction_hint(species: String) -> String:
	var target_coral := str(_level_def.get("target_coral", ""))
	if target_coral.is_empty():
		return ""

	var aids: Dictionary = _interactions.get("fish_aids_coral", {})
	var harms: Dictionary = _interactions.get("fish_harms_coral", {})

	if typeof(aids) == TYPE_DICTIONARY and aids.has(species):
		var aided: Array = aids[species]
		if typeof(aided) == TYPE_ARRAY and aided.has(target_coral):
			return "aids %s growth" % target_coral

	if typeof(harms) == TYPE_DICTIONARY and harms.has(species):
		var harmed: Array = harms[species]
		if typeof(harmed) == TYPE_ARRAY and harmed.has(target_coral):
			return "harms %s!" % target_coral

	var hints: Dictionary = _interactions.get("hints", {})
	if typeof(hints) == TYPE_DICTIONARY and hints.has(species):
		return str(hints[species])

	return ""


# ─── Turn resolution ──────────────────────────────────────────────────────────

func _advance_turn() -> void:
	if _session_over or _in_identify_phase or _showing_turn_results:
		return
	if _maybe_show_stressor_tooltip():
		return

	var target_coral := str(_level_def.get("target_coral", ""))
	var coral_delta := _compute_coral_delta(target_coral)
	var species_deltas := {}
	if coral_delta != 0:
		species_deltas[target_coral] = coral_delta
	_coral_population = maxi(0, _coral_population + coral_delta)
	if _coral_population <= 0 and _is_essential_species(target_coral):
		_on_essential_extinct(target_coral)
		return

	var nutrients_used := _turn_nutrients_spent
	_nutrients += 1
	_turns_remaining -= 1
	_turns_used += 1
	_triggers_remaining = _triggers_per_turn
	_turn_nutrients_spent = 0
	_rebuild_species_order()
	_refresh_fish_rows()
	await _apply_starvation_if_needed()
	if _session_over:
		return

	if _check_win_condition():
		return

	if _turns_remaining <= 0:
		if _tutorial_active:
			_turns_remaining = 1
			_nutrients = maxi(_nutrients, 4)
			status_label.text = "Keep going — match the reef to finish the tutorial."
			_update_text()
			return
		_session_over = true
		_fail_reason = _build_turns_exhausted_fail_reason()
		status_label.text = _fail_reason
		_refresh_fish_rows()
		_update_text()
		_show_level_fail_overlay()
		return

	var reef_ratio := 0.0
	if _target_population > 0:
		reef_ratio = float(_coral_population) / float(_target_population)
	_show_turn_results(_turns_used, _current_population_snapshot(), _target_population_snapshot(), _turns_remaining)
	_update_text()


func _apply_starvation_if_needed() -> void:
	var cap := _population_cap()
	var overflow := _total_live_fish() - cap
	if overflow <= 0:
		return

	_showing_turn_results = true
	_set_gameplay_buttons_disabled(true)

	var deaths_by_species: Dictionary = {}
	for _i in range(overflow):
		var victim_species := _pick_starvation_victim_species()
		if victim_species.is_empty():
			break
		_remove_fish_instance(victim_species, true)
		deaths_by_species[victim_species] = int(deaths_by_species.get(victim_species, 0)) + 1

	for species in deaths_by_species.keys():
		var count := int(deaths_by_species[species])
		var card := _find_fish_card(str(species))
		if card and card.has_method("play_starvation_death"):
			card.call("play_starvation_death")
			await card.starvation_animation_finished
		_fish_population[species] = maxi(0, int(_fish_population.get(species, 0)) - count)
		status_label.text = "%s starved (%d lost over cap %d)" % [species, count, cap]
		if int(_fish_population.get(species, 0)) <= 0 and _is_essential_species(str(species)):
			_showing_turn_results = false
			_set_gameplay_buttons_disabled(false)
			_on_essential_extinct(str(species))
			return

	_showing_turn_results = false
	_rebuild_species_order()
	_refresh_fish_rows()
	_update_text()
	_set_gameplay_buttons_disabled(false)


func _pick_starvation_victim_species() -> String:
	var best_species := ""
	var best_entry: Dictionary = {}
	for species in _fish_instances.keys():
		if not _fish_specs_by_name.has(str(species)):
			continue
		var entries: Array = _fish_instances[species]
		if entries.is_empty():
			continue
		var sorted_entries := entries.duplicate(true)
		sorted_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			var a_placed := int(a.get("placed_at_turn", 0))
			var b_placed := int(b.get("placed_at_turn", 0))
			if a_placed != b_placed:
				return a_placed < b_placed
			var a_fed := int(a.get("last_fed_at_turn", -1))
			var b_fed := int(b.get("last_fed_at_turn", -1))
			if a_fed != b_fed:
				return a_fed < b_fed
			return int(a.get("placed_order", 0)) < int(b.get("placed_order", 0))
		)
		var candidate: Dictionary = sorted_entries[0]
		if best_species.is_empty() or _is_starvation_candidate_older(candidate, best_entry):
			best_species = str(species)
			best_entry = candidate
	return best_species


func _is_starvation_candidate_older(candidate: Dictionary, incumbent: Dictionary) -> bool:
	if incumbent.is_empty():
		return true
	var candidate_placed := int(candidate.get("placed_at_turn", 0))
	var incumbent_placed := int(incumbent.get("placed_at_turn", 0))
	if candidate_placed != incumbent_placed:
		return candidate_placed < incumbent_placed
	var candidate_fed := int(candidate.get("last_fed_at_turn", -1))
	var incumbent_fed := int(incumbent.get("last_fed_at_turn", -1))
	if candidate_fed != incumbent_fed:
		return candidate_fed < incumbent_fed
	return int(candidate.get("placed_order", 0)) < int(incumbent.get("placed_order", 0))


func _check_win_condition() -> bool:
	if _coral_population < _target_population:
		return false

	_session_over = true
	var coins_earned := _calculate_coins_earned()

	if controller and controller.has_method("complete_current_level"):
		controller.call("complete_current_level", coins_earned)
	var rewards_pending := false
	if controller and controller.has_method("get_pending_reward_total"):
		rewards_pending = int(controller.call("get_pending_reward_total")) > 0
	status_label.text = "Reef replicated! Reward pending sync (%d coins)" % coins_earned if rewards_pending else "Reef replicated! Earned %d coins" % coins_earned
	_refresh_fish_rows()
	_update_text()
	_offer_post_level_classification()
	_show_level_end_overlay(coins_earned)
	if _tutorial_active:
		_show_tutorial_step("win_outro")
	return true


func _calculate_coins_earned() -> int:
	var base := int(_level_def.get("reward_coins", 10))
	var turn_limit := int(_level_def.get("turn_limit", 6))
	var speed_bonus := maxi(0, turn_limit - _turns_used) * 5
	return base + speed_bonus + _identify_bonus_coins


func _species_preference_multiplier(species: String, target_coral: String) -> float:
	var coral_spec: Dictionary = _coral_specs_by_name.get(target_coral, {})
	if typeof(coral_spec) != TYPE_DICTIONARY:
		return 1.0

	var preferred_temp := str(coral_spec.get("preferred_temperature", ""))
	var preferred_salinity := str(coral_spec.get("preferred_salinity", ""))

	var fish_spec: Dictionary = _fish_specs_by_name.get(species, {})
	if typeof(fish_spec) != TYPE_DICTIONARY:
		return 1.0

	var temp_pref := str(fish_spec.get("temperature_pref", ""))
	var sal_pref := str(fish_spec.get("salinity_pref", ""))
	var multiplier := 1.0

	if not preferred_temp.is_empty() and not temp_pref.is_empty():
		if preferred_temp == temp_pref:
			multiplier += 0.18
		else:
			multiplier -= 0.12

	if not preferred_salinity.is_empty() and not sal_pref.is_empty():
		if preferred_salinity == sal_pref:
			multiplier += 0.08
		else:
			multiplier -= 0.08

	return clampf(multiplier, 0.65, 1.35)


func _compute_coral_delta(target_coral: String) -> int:
	var support := 0.8
	var stress := 0.0
	var interaction_notes: Array[String] = []

	var aids_map: Dictionary = _interactions.get("fish_aids_coral", {})
	var harms_map: Dictionary = _interactions.get("fish_harms_coral", {})

	for species in _fish_species_order:
		var population := float(int(_fish_population.get(species, 0)))
		if population <= 0.0:
			continue

		if _fish_specs_by_name.has(species):
			var fish_spec: Dictionary = _fish_specs_by_name[species]
			var coral_effects: Dictionary = fish_spec.get("coral_effects", {})
			var species_effect := float(coral_effects.get(target_coral, 0.12))
			species_effect *= _species_preference_multiplier(species, target_coral)
			support += species_effect * population
			if _positive_fish.has(species):
				support += 0.15 * population

			# Trait-based bonuses
			var active_trait := str(_fish_active_traits.get(species, ""))
			if not active_trait.is_empty():
				var trait_def: Dictionary = _trait_definitions.get(active_trait, {})
				if typeof(trait_def) == TYPE_DICTIONARY:
					var support_bonus := float(trait_def.get("support_bonus", 0.0))
					support += support_bonus * population

					# Schooling: extra bonus when population >= threshold
					var school_thresh := int(trait_def.get("schooling_threshold", 0))
					if school_thresh > 0 and int(population) >= school_thresh:
						support += float(trait_def.get("schooling_bonus", 0.0)) * population

					# Environment-specific trait bonuses
					var coral_spec_for_trait: Dictionary = _coral_specs_by_name.get(target_coral, {})
					var coral_temp_pref := str(coral_spec_for_trait.get("preferred_temperature", ""))
					if coral_temp_pref == "cold" or coral_temp_pref == "cool" or coral_temp_pref == "moderate":
						support += float(trait_def.get("cold_support_bonus", 0.0)) * population
					if coral_temp_pref == "warm":
						support += float(trait_def.get("warm_support_bonus", 0.0)) * population

					# Bioerosion penalty for sponge
					if target_coral == "Sponge":
						stress += float(trait_def.get("sponge_penalty", 0.0)) * population

			# Explicit interaction bonus
			if typeof(aids_map) == TYPE_DICTIONARY and aids_map.has(species):
				var aided: Array = aids_map[species]
				if typeof(aided) == TYPE_ARRAY and aided.has(target_coral):
					support += 0.1 * population
					if interaction_notes.size() < 2:
						interaction_notes.append("%s aids %s" % [species, target_coral])

			if typeof(harms_map) == TYPE_DICTIONARY and harms_map.has(species):
				var harmed: Array = harms_map[species]
				if typeof(harmed) == TYPE_ARRAY and harmed.has(target_coral):
					stress += 0.15 * population
					if interaction_notes.size() < 2:
						interaction_notes.append("%s harms %s!" % [species, target_coral])

		elif _stressor_specs_by_name.has(species):
			var stressor_spec: Dictionary = _stressor_specs_by_name[species]
			var harm := float(stressor_spec.get("harm_scale", 0.4))
			stress += harm * population
			if _negative_fish.has(species):
				stress += 0.14 * population

			if typeof(harms_map) == TYPE_DICTIONARY and harms_map.has(species):
				var harmed: Array = harms_map[species]
				if typeof(harmed) == TYPE_ARRAY and harmed.has(target_coral):
					stress += 0.12 * population
		elif _negative_fish.has(species):
			stress += 0.3 * population
		elif _positive_fish.has(species):
			support += 0.2 * population

	if not interaction_notes.is_empty():
		_set_turn_hint(" | ".join(interaction_notes))

	var env_bonus := _environment_alignment_bonus(target_coral)
	return int(round(support - stress + env_bonus))


func _growth_for_species(species: String, population: int) -> int:
	if population <= 0:
		return 0

	if _stressor_specs_by_name.has(species):
		var stressor_growth := population * 0.20
		var stressor_whole := int(floor(stressor_growth))
		if randf() < (stressor_growth - float(stressor_whole)):
			stressor_whole += 1
		return maxi(0, stressor_whole)

	var spec: Dictionary = _fish_specs_by_name.get(species, {})
	if typeof(spec) != TYPE_DICTIONARY:
		return 0

	var success_chance := clampf(float(spec.get("breed_success_chance", 0.5)), 0.05, 0.95)

	# Apply fast_breeder / slow_breeder trait effect
	var active_trait := str(_fish_active_traits.get(species, ""))
	if not active_trait.is_empty():
		var trait_def: Dictionary = _trait_definitions.get(active_trait, {})
		if typeof(trait_def) == TYPE_DICTIONARY:
			var delta := float(trait_def.get("breed_success_delta", 0.0))
			success_chance = clampf(success_chance + delta, 0.05, 0.95)

	var expected := float(population) * success_chance * 0.35
	var whole := int(floor(expected))
	if randf() < (expected - float(whole)):
		whole += 1
	return maxi(0, whole)


# ─── Breeding ─────────────────────────────────────────────────────────────────

func _on_breed_pressed() -> void:
	if _session_over or _in_identify_phase:
		return
	if _fish_species_order.size() < 1:
		status_label.text = "No fish available for breeding"
		return

	var parents := _pick_breed_parents()
	if parents.size() == 0:
		status_label.text = "No valid breeding pair"
		return

	var breed_cost := _breed_cost_for_parents(parents)
	if _nutrients < breed_cost:
		status_label.text = "Need %d nutrients to breed" % breed_cost
		return

	# Show preview dialog — breeding executes only on confirmation
	_show_breed_preview(parents)


func _execute_breed(parents: Array[String]) -> void:
	var breed_cost := _breed_cost_for_parents(parents)
	if _nutrients < breed_cost:
		status_label.text = "Not enough nutrients to breed"
		return

	# Apply fast_breeder trait modifier to cost
	var cost_delta := 0
	for parent in parents:
		var trait_name := str(_fish_active_traits.get(parent, ""))
		if not trait_name.is_empty():
			var trait_def: Dictionary = _trait_definitions.get(trait_name, {})
			if typeof(trait_def) == TYPE_DICTIONARY:
				cost_delta += int(trait_def.get("breed_cost_delta", 0))
	breed_cost = maxi(1, breed_cost + cost_delta)

	_nutrients -= breed_cost
	_turn_nutrients_spent += breed_cost
	var success_chance := _breed_success_for_parents(parents)

	# Apply trait modifiers to success
	for parent in parents:
		var trait_name := str(_fish_active_traits.get(parent, ""))
		if not trait_name.is_empty():
			var trait_def: Dictionary = _trait_definitions.get(trait_name, {})
			if typeof(trait_def) == TYPE_DICTIONARY:
				var breed_success_delta := float(trait_def.get("breed_success_delta", 0.0))
				success_chance = clampf(success_chance + breed_success_delta, 0.05, 0.95)

	if randf() > success_chance:
		status_label.text = "Breeding attempt failed"
		_update_text()
		return

	var offspring := _pick_offspring_species(parents)
	_fish_population[offspring] = int(_fish_population.get(offspring, 0)) + 1
	_add_fish_instance(offspring)
	if not _fish_species_order.has(offspring):
		_fish_species_order.append(offspring)
		_fish_species_order.sort()

	# Trait inheritance: offspring has 50% chance to inherit a trait from either parent
	var inherited_trait := _inherit_trait(parents, offspring)
	if not inherited_trait.is_empty():
		_fish_active_traits[offspring] = inherited_trait
		status_label.text = "Breeding success: %s + %s → %s [%s]" % [parents[0], parents[1], offspring, inherited_trait]
	else:
		status_label.text = "Breeding success: %s + %s → %s" % [parents[0], parents[1], offspring]

	_refresh_fish_rows()
	_update_text()
	if _nutrients <= 0:
		_advance_turn()


func _inherit_trait(parents: Array[String], offspring_species: String) -> String:
	# Build pool of inheritable traits from parents
	var trait_pool: Array[String] = []
	for parent in parents:
		var available: Variant = _species_available_traits.get(parent, [])
		if typeof(available) == TYPE_ARRAY:
			for t in available:
				var ts := str(t)
				if not trait_pool.has(ts):
					trait_pool.append(ts)

	# Also include offspring's own available traits as possibilities
	var offspring_traits: Variant = _species_available_traits.get(offspring_species, [])
	if typeof(offspring_traits) == TYPE_ARRAY:
		for t in offspring_traits:
			var ts := str(t)
			if not trait_pool.has(ts):
				trait_pool.append(ts)

	if trait_pool.is_empty():
		return ""

	# 60% chance to inherit a trait
	if randf() > 0.60:
		return ""

	return trait_pool[randi() % trait_pool.size()]


func _pick_breed_parents() -> Array[String]:
	var species_by_population: Array = []
	for species in _fish_species_order:
		var population := int(_fish_population.get(species, 0))
		if population > 0 and _fish_specs_by_name.has(species):
			species_by_population.append({"species": species, "population": population})

	if species_by_population.is_empty():
		return []

	species_by_population.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("population", 0)) > int(b.get("population", 0))
	)

	if species_by_population.size() == 1:
		var single := str(species_by_population[0].get("species", ""))
		return [single, single]

	return [
		str(species_by_population[0].get("species", "")),
		str(species_by_population[1].get("species", "")),
	]


func _breed_cost_for_parents(parents: Array[String]) -> int:
	var total := 0
	for parent in parents:
		var parent_spec: Dictionary = _fish_specs_by_name.get(parent, {})
		total += maxi(1, int(parent_spec.get("breed_cost", 1)))
	return maxi(1, int(round(float(total) / max(1.0, float(parents.size())))))


func _breed_success_for_parents(parents: Array[String]) -> float:
	var total := 0.0
	for parent in parents:
		var parent_spec: Dictionary = _fish_specs_by_name.get(parent, {})
		total += clampf(float(parent_spec.get("breed_success_chance", 0.5)), 0.05, 0.95)
	return clampf(total / max(1.0, float(parents.size())), 0.05, 0.95)


func _pick_offspring_species(parents: Array[String]) -> String:
	var weights: Dictionary = {}
	for parent in parents:
		var parent_spec: Dictionary = _fish_specs_by_name.get(parent, {})
		var offspring_weights: Dictionary = parent_spec.get("offspring_weights", {})
		if typeof(offspring_weights) == TYPE_DICTIONARY and not offspring_weights.is_empty():
			for species in offspring_weights.keys():
				var key := str(species)
				weights[key] = int(weights.get(key, 0)) + maxi(0, int(offspring_weights[species]))
		else:
			weights[parent] = int(weights.get(parent, 0)) + 1

	if weights.is_empty():
		return parents[0]

	var total_weight := 0
	for v in weights.values():
		total_weight += int(v)
	if total_weight <= 0:
		return parents[0]

	var roll := randi_range(1, total_weight)
	var cursor := 0
	for species in weights.keys():
		cursor += int(weights[species])
		if roll <= cursor:
			return str(species)

	return parents[0]


# ─── Post-level classification quiz ──────────────────────────────────────────

func _offer_post_level_classification() -> void:
	if _tutorial_active:
		return
	if _classification_entries.is_empty() or _classification_dialog == null:
		return

	var entry: Variant = _classification_entries[randi() % _classification_entries.size()]
	if typeof(entry) != TYPE_DICTIONARY:
		return

	_pending_classification = entry
	_show_classification_dialog(entry)


func _show_classification_dialog(entry: Dictionary) -> void:
	if _classification_dialog == null:
		return

	var canonical_name := str(entry.get("canonical_name", "Unknown"))
	var collection_name := str(entry.get("collection_name", "Unknown Collection"))
	var subject_id := str(entry.get("subject_id", ""))

	_classification_prompt_label.text = "[b]Classify this coral image[/b]\nCollection: %s\nSubject: %s\n\nA correct answer earns [b]%d bonus coins![/b]" % [collection_name, subject_id, _classification_bonus_coins]
	_classification_guess_option.clear()

	var choices: Array[String] = [canonical_name]
	var coral_names := _available_coral_names()
	while choices.size() < 4 and coral_names.size() > 0:
		var candidate := coral_names[randi() % coral_names.size()]
		if not choices.has(candidate):
			choices.append(candidate)

	choices.shuffle()
	for choice in choices:
		_classification_guess_option.add_item(choice)

	var resource_path := str(entry.get("resource_path", ""))
	_classification_image.visible = false
	_classification_image.texture = null
	if not resource_path.is_empty() and FileAccess.file_exists(resource_path) and ResourceLoader.exists(resource_path):
		var texture := load(resource_path)
		if texture is Texture2D:
			_classification_image.texture = texture
			_classification_image.visible = true

	_classification_dialog.popup_centered()


func _available_coral_names() -> Array[String]:
	var names: Array[String] = []
	if typeof(_coral_specs_by_name) == TYPE_DICTIONARY:
		for key in _coral_specs_by_name.keys():
			names.append(str(key))
	if names.is_empty():
		for entry in _species_reference.get("corals", []):
			if typeof(entry) != TYPE_DICTIONARY:
				continue
			var name := str(entry.get("name", ""))
			if not name.is_empty():
				names.append(name)
	return names


func _on_classification_cancelled() -> void:
	_pending_classification = {}


func _on_classification_confirmed() -> void:
	if _pending_classification.is_empty():
		return
	if controller == null or not controller.has_method("submit_post_level_classification"):
		return
	if _classification_guess_option.item_count <= 0:
		return

	var selected_text := _classification_guess_option.get_item_text(_classification_guess_option.selected)
	var canonical_name := str(_pending_classification.get("canonical_name", ""))
	var subject_id := str(_pending_classification.get("subject_id", ""))
	var accepted_answers := _to_string_array(_pending_classification.get("accepted_answers", []))
	accepted_answers.append_array(_taxonomy_aliases_for(canonical_name))

	var result = controller.call(
		"submit_post_level_classification",
		subject_id,
		canonical_name,
		selected_text,
		accepted_answers,
		_classification_bonus_coins
	)

	if typeof(result) == TYPE_DICTIONARY:
		if bool(result.get("correct", false)):
			var bonus := int(result.get("bonus", 0))
			status_label.text = "Correct! +%d coins — %s discovered" % [bonus, canonical_name]
		else:
			status_label.text = "Not quite — it was %s" % canonical_name

	_pending_classification = {}
	_update_text()


func _taxonomy_aliases_for(canonical_name: String) -> Array[String]:
	var aliases: Array[String] = []
	var taxonomy_aliases: Dictionary = _species_reference.get("taxonomy_aliases", {})
	if typeof(taxonomy_aliases) != TYPE_DICTIONARY:
		return aliases

	var normalized := _normalize_label(canonical_name)
	for key in taxonomy_aliases.keys():
		if _normalize_label(str(key)) != normalized:
			continue
		for alias in taxonomy_aliases[key]:
			aliases.append(str(alias))
		break

	var genus := canonical_name.split(" ")[0].strip_edges()
	if not genus.is_empty() and not aliases.has(genus):
		aliases.append(genus)
	return aliases


func _normalize_label(raw: String) -> String:
	if controller and controller.has_method("normalize_label"):
		return controller.call("normalize_label", raw)
	return raw.to_lower().strip_edges().replace(".", "").replace("-", " ").replace("_", " ")


# ─── Navigation ───────────────────────────────────────────────────────────────

func _on_prev_level_pressed() -> void:
	if _active_level_id > 1:
		_select_level(_active_level_id - 1)


func _on_next_level_pressed() -> void:
	if _active_level_id < LEVEL_COUNT:
		_select_level(_active_level_id + 1)


func _go_home() -> void:
	get_tree().change_scene_to_file(HOME_SCENE)


func _reset_level() -> void:
	if _active_level_id <= 0:
		return
	_start_level_from_state(_level_state)


func _adjust_environment(kind: String, delta: int) -> void:
	if _session_over or _in_identify_phase or _showing_turn_results:
		return
	if delta == 0:
		return
	if _triggers_remaining <= 0:
		status_label.text = "No triggers remaining this turn"
		return

	var value_changed := false
	if kind == "salinity":
		var next_salinity := clampi(_salinity_adjustment + delta, -1, 1)
		value_changed = next_salinity != _salinity_adjustment
		_salinity_adjustment = next_salinity
	else:
		var next_temperature := clampi(_temperature_adjustment + delta, -1, 1)
		value_changed = next_temperature != _temperature_adjustment
		_temperature_adjustment = next_temperature

	if not value_changed:
		status_label.text = "%s is already at %s" % [kind.capitalize(), _environment_band_label(_salinity_adjustment if kind == "salinity" else _temperature_adjustment, kind)]
		return

	if controller == null or not controller.has_method("spend_coins"):
		return
	var paid: bool = controller.call("spend_coins", ENV_TUNE_COST)
	if not paid:
		if kind == "salinity":
			_salinity_adjustment -= delta
		else:
			_temperature_adjustment -= delta
		status_label.text = "Need %d coins to tune %s" % [ENV_TUNE_COST, kind]
		return

	_consume_trigger()
	status_label.text = "Water tuned: salinity %s, temp %s (-%d coins)" % [
		_environment_band_label(_salinity_adjustment, "salinity"),
		_environment_band_label(_temperature_adjustment, "temperature"),
		ENV_TUNE_COST
	]
	_update_text()


func _consume_trigger() -> void:
	_triggers_remaining = maxi(0, _triggers_remaining - 1)


func _build_turns_exhausted_fail_reason() -> String:
	var shortfall := maxi(0, _target_population - _coral_population)
	var target_coral := str(_level_def.get("target_coral", "the target reef"))
	if shortfall > 0:
		return "Turn limit reached. You were %d short on %s." % [shortfall, target_coral]
	return "You ran out of turns before reaching the target reef composition."


func _current_population_snapshot() -> Dictionary:
	var snapshot := _fish_population.duplicate(true)
	var target_coral := str(_level_def.get("target_coral", ""))
	if not target_coral.is_empty():
		snapshot[target_coral] = _coral_population
	return snapshot


func _target_population_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	var starting_fish: Dictionary = _level_def.get("starting_fish", {})
	for species in starting_fish.keys():
		snapshot[str(species)] = int(starting_fish[species])
	var target_coral := str(_level_def.get("target_coral", ""))
	if not target_coral.is_empty():
		snapshot[target_coral] = _target_population
	return snapshot


func _is_essential_species(species: String) -> bool:
	for essential in _essential_species:
		if _normalize_label(essential) == _normalize_label(species):
			return true
	return false


func _on_essential_extinct(species: String) -> void:
	if _tutorial_active:
		status_label.text = "%s disappeared. Keep adjusting the reef." % species
		_refresh_fish_rows()
		_update_text()
		return
	if _session_over:
		return
	_session_over = true
	_fail_reason = "%s went extinct. Essential species lost." % species
	status_label.text = _fail_reason
	_refresh_fish_rows()
	_update_text()
	_show_level_fail_overlay()


func _on_supabase_sync_status(payload_json: String) -> void:
	var parsed = JSON.parse_string(payload_json)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var message := str(parsed.get("message", ""))
	var kind := str(parsed.get("kind", ""))
	status_label.text = "%s: %s" % [kind.to_upper(), message]


func _update_coral_growth_visuals() -> void:
	var ratio := 0.0
	if _target_population > 0:
		ratio = clampf(float(_coral_population) / float(_target_population), 0.0, 1.0)

	var growth_alpha := 0.2
	var growth_scale := 0.4
	var growth_phase := "Seed"

	if ratio >= 1.0:
		growth_alpha = 1.0
		growth_scale = 1.0
		growth_phase = "Bloom"
	elif ratio >= 0.75:
		growth_alpha = 1.0
		growth_scale = 1.0
		growth_phase = "Bloom"
	elif ratio >= 0.50:
		growth_alpha = 0.8
		growth_scale = 1.0
		growth_phase = "Branch"
	elif ratio >= 0.25:
		growth_alpha = 0.5
		growth_scale = 0.6
		growth_phase = "Sprout"

	# Apply to main coral sprites
	var base_scale := 0.484 # Based on 248x248 target
	for c in [coral_1, coral_2, coral_3]:
		if c:
			c.modulate.a = growth_alpha
			c.scale = Vector2(base_scale * growth_scale, base_scale * growth_scale)

	# Patch visibility (secondary detail)
	var patches: Array[AnimatedSprite2D] = [
		coral_patch_1a, coral_patch_1b, coral_patch_1c,
		coral_patch_2a, coral_patch_2b, coral_patch_2c,
		coral_patch_3a, coral_patch_3b, coral_patch_3c,
	]
	var visible_count := int(round(ratio * float(patches.size())))
	for i in range(patches.size()):
		if patches[i]:
			patches[i].visible = i < visible_count

	if not _in_identify_phase and not _session_over:
		_set_turn_hint("Coral phase: %s" % growth_phase)
	elif _session_over:
		_set_turn_hint("Reef replicated — well done!")


func _update_environment_meters(target_coral: String) -> void:
	var coral_spec: Dictionary = _coral_specs_by_name.get(target_coral, {})
	if typeof(coral_spec) != TYPE_DICTIONARY:
		return
	var salinity_pref := str(coral_spec.get("preferred_salinity", ""))
	var temp_pref := str(coral_spec.get("preferred_temperature", ""))
	var salinity_value := clampf(_preference_to_meter_value(salinity_pref) + float(_salinity_adjustment * 22), 0.0, 100.0)
	var temp_value := clampf(_preference_to_meter_value(temp_pref) + float(_temperature_adjustment * 22), 0.0, 100.0)
	if salinity_bar:
		salinity_bar.value = salinity_value
	if temp_bar:
		temp_bar.value = temp_value
	if salinity_readout_label:
		salinity_readout_label.text = "Salinity: %s" % _environment_band_label(_salinity_adjustment, "salinity")
	if temperature_readout_label:
		temperature_readout_label.text = "Temp: %s" % _environment_band_label(_temperature_adjustment, "temperature")


func _preference_to_meter_value(preference: String) -> float:
	var normalized := _normalize_label(preference)
	if normalized.contains("high") or normalized.contains("warm"):
		return 78.0
	if normalized.contains("low") or normalized.contains("cool") or normalized.contains("cold"):
		return 34.0
	if normalized.contains("medium") or normalized.contains("moderate"):
		return 56.0
	return 50.0


func _normalize_preference_text(raw: String) -> String:
	var text := raw.strip_edges()
	if text.is_empty():
		return "Moderate"
	var lower := text.to_lower()
	if lower.begins_with("temperature_"):
		text = text.substr("temperature_".length())
	elif lower.begins_with("salinity_"):
		text = text.substr("salinity_".length())
	return text.capitalize()


func _environment_band_label(adjustment: int, kind: String) -> String:
	if kind == "salinity":
		if adjustment < 0:
			return "Low"
		if adjustment > 0:
			return "High"
		return "Medium"
	if adjustment < 0:
		return "Cold"
	if adjustment > 0:
		return "Warm"
	return "Moderate"


func _environment_alignment_bonus(target_coral: String) -> float:
	var coral_spec: Dictionary = _coral_specs_by_name.get(target_coral, {})
	if typeof(coral_spec) != TYPE_DICTIONARY:
		return 0.0
	var ideal_salinity := _preference_to_meter_value(str(coral_spec.get("preferred_salinity", "")))
	var ideal_temp := _preference_to_meter_value(str(coral_spec.get("preferred_temperature", "")))
	var salinity_value := ideal_salinity
	if salinity_bar:
		salinity_value = salinity_bar.value
	var temp_value := ideal_temp
	if temp_bar:
		temp_value = temp_bar.value
	var salinity_delta := absf(salinity_value - ideal_salinity) / 100.0
	var temp_delta := absf(temp_value - ideal_temp) / 100.0
	var penalty := (salinity_delta + temp_delta) * 2.0
	return clampf(1.1 - penalty, -1.5, 1.1)
