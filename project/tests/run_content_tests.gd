extends SceneTree

func _fail(message: String) -> void:
	printerr(message)
	quit(1)

func _init() -> void:
	var levels_path := "res://data/starter_levels.json"
	var species_path := "res://data/species_reference.json"
	var click_a_coral_path := "res://data/click_a_coral_subjects.json"

	if not FileAccess.file_exists(levels_path):
		_fail("Missing starter levels JSON")
		return
	if not FileAccess.file_exists(species_path):
		_fail("Missing species reference JSON")
		return
	if not FileAccess.file_exists(click_a_coral_path):
		_fail("Missing click_a_coral_subjects.json")
		return

	var levels_doc = JSON.parse_string(FileAccess.get_file_as_string(levels_path))
	if typeof(levels_doc) != TYPE_DICTIONARY:
		_fail("starter_levels.json is not a dictionary")
		return

	var levels: Array = levels_doc.get("levels", [])
	if levels.size() != 10:
		_fail("Expected 10 levels, got %d" % levels.size())
		return
	if str(levels_doc.get("economy", {}).get("completion_bonus_currency", "")) != "coins":
		_fail("Expected completion bonus currency to be coins")
		return

	for idx in range(levels.size()):
		var level: Dictionary = levels[idx]
		if not level.has("target_coral") or not level.has("starting_nutrients") or not level.has("reward_coins"):
			_fail("Level %d missing required fields" % int(level.get("id", idx + 1)))
			return
		if level.has("starting_fishfood") or level.has("reward_fishfood"):
			_fail("Level %d still uses deprecated fishfood fields" % int(level.get("id", idx + 1)))
			return

	var species_doc = JSON.parse_string(FileAccess.get_file_as_string(species_path))
	if typeof(species_doc) != TYPE_DICTIONARY:
		_fail("species_reference.json is not a dictionary")
		return
	if species_doc.get("corals", []).size() < 12:
		_fail("Expected at least 12 coral entries")
		return
	if species_doc.get("fish_species", []).size() < 5:
		_fail("Expected at least 5 fish species entries")
		return
	for fish in species_doc.get("fish_species", []):
		if typeof(fish) != TYPE_DICTIONARY:
			_fail("fish_species contains non-dictionary entry")
			return
		if not fish.has("name") or not fish.has("coral_effects") or not fish.has("offspring_weights"):
			_fail("fish species entry missing ecology/breeding fields")
			return
	var trait_definitions: Variant = species_doc.get("trait_definitions", {})
	if typeof(trait_definitions) != TYPE_DICTIONARY or trait_definitions.is_empty():
		_fail("species_reference.json is missing trait_definitions")
		return
	var species_traits: Variant = species_doc.get("species_traits", {})
	if typeof(species_traits) != TYPE_DICTIONARY:
		_fail("species_reference.json is missing species_traits")
		return
	for coral in species_doc.get("corals", []):
		if typeof(coral) != TYPE_DICTIONARY:
			continue
		var coral_name := str(coral.get("name", ""))
		if coral_name.is_empty():
			continue
		if not species_traits.has(coral_name):
			_fail("species_traits missing coral entry for %s" % coral_name)
			return

	var tutorial_steps_path := "res://data/tutorial_steps.json"
	if not FileAccess.file_exists(tutorial_steps_path):
		_fail("Missing tutorial_steps.json")
		return
	var tutorial_steps_doc: Variant = JSON.parse_string(FileAccess.get_file_as_string(tutorial_steps_path))
	if typeof(tutorial_steps_doc) != TYPE_DICTIONARY:
		_fail("tutorial_steps.json is not a dictionary")
		return
	var tutorial_steps: Variant = tutorial_steps_doc.get("steps", {})
	if typeof(tutorial_steps) != TYPE_DICTIONARY:
		_fail("tutorial_steps.json is missing steps")
		return
	for required_step in ["identify_intro", "goal_intro", "feed_action", "end_turn_action", "results_intro", "egg_intro", "win_outro"]:
		if not tutorial_steps.has(required_step):
			_fail("tutorial_steps.json is missing %s" % required_step)
			return

	var app_controller_script = load("res://app_controller.gd")
	var app_controller = app_controller_script.new()
	app_controller._load_content_data()
	var level_system_script = load("res://level_system.gd")
	var level_system = level_system_script.new()
	if level_system == null:
		_fail("Failed to instantiate level_system.gd")
		return
	level_system._build_level_fail_overlay()
	if level_system._level_fail_overlay == null or level_system._level_fail_stats_label == null:
		_fail("Level fail overlay was not constructed")
		return
	level_system._level_def = {"reward_coins": 10, "turn_limit": 6}
	level_system._turns_used = 2
	level_system._identify_bonus_coins = 5
	if level_system._calculate_coins_earned() != 35:
		_fail("Expected speed bonus formula to use 5 coins per unused turn")
		return

	var loaded_levels = JSON.parse_string(app_controller.get_puzzle_levels_json())
	if typeof(loaded_levels) != TYPE_ARRAY or loaded_levels.size() != 10:
		_fail("AppController did not expose 10 levels")
		return

	var loaded_species = JSON.parse_string(app_controller.get_species_reference_json())
	if typeof(loaded_species) != TYPE_DICTIONARY:
		_fail("AppController did not expose species reference")
		return
	if app_controller.get_cached_subject_image_path("missing-subject") != "":
		_fail("Expected empty cache path for unknown subject id")
		return

	var spent: bool = app_controller.spend_coins(1)
	if spent:
		_fail("AppController allowed spending coins before any were awarded")
		return

	app_controller.add_coins(12)
	if app_controller.get_coins() != 12:
		_fail("Expected coins to accumulate after add_coins")
		return

	app_controller.add_carryover_triggers(2)
	if app_controller.get_carryover_triggers() != 2:
		_fail("Expected carryover triggers to accumulate")
		return
	if app_controller.consume_carryover_triggers(1) != 1:
		_fail("Expected one carryover trigger to be consumed")
		return
	if app_controller.get_carryover_triggers() != 1:
		_fail("Carryover trigger total did not decrease after consume")
		return

	if not app_controller.spend_coins(5):
		_fail("Expected spend_coins to succeed after adding coins")
		return

	if app_controller.get_coins() != 7:
		_fail("Coin total did not decrease after spend_coins")
		return

	var state_after_classification = app_controller.submit_post_level_classification(
		"seed-subject",
		"Madracis Sp.",
		"madracis",
		["Madracis Sp.", "madracis"],
		3
	)
	if typeof(state_after_classification) != TYPE_DICTIONARY:
		_fail("submit_post_level_classification did not return dictionary")
		return
	if not bool(state_after_classification.get("correct", false)):
		_fail("Expected lenient classification to pass")
		return

	var coins_before_completion: int = app_controller.get_coins()
	var completion_state: Dictionary = app_controller.complete_current_level(9)
	if typeof(completion_state) != TYPE_DICTIONARY:
		_fail("complete_current_level did not return dictionary")
		return
	if app_controller.get_coins() != coins_before_completion:
		_fail("Coins should remain pending until sync succeeds")
		return
	if int(completion_state.get("pending_reward_total", 0)) != 9:
		_fail("Expected pending reward total to reflect unsynced win reward")
		return

	var state = JSON.parse_string(app_controller.get_level_state_json())
	if typeof(state) != TYPE_DICTIONARY:
		_fail("AppController state JSON is invalid")
		return
	# Verify nutrients are exposed correctly (level 1 has 12 starting_nutrients)
	if int(state.get("current_level_available_nutrients", 0)) < 5:
		_fail("Level nutrients provisioning is unexpectedly low")
		return

	# Verify coins are tracked
	if not state.has("global_coins"):
		_fail("global_coins missing from AppController state")
		return
	if int(state.get("carryover_triggers", -1)) != 1:
		_fail("carryover_triggers missing or incorrect in AppController state")
		return

	# Verify tank state is present
	if not state.has("tank"):
		_fail("tank state missing from AppController state")
		return

	var resource_bar_scene := load("res://scenes/layout/BottomResourceBar.tscn")
	if resource_bar_scene == null:
		_fail("Failed to load BottomResourceBar scene")
		return

	var tutorial_overlay_scene := load("res://scenes/ui/TutorialOverlay.tscn")
	if tutorial_overlay_scene == null:
		_fail("Failed to load TutorialOverlay scene")
		return

	var resource_bar: Node = resource_bar_scene.instantiate()
	if resource_bar == null:
		_fail("Failed to instantiate BottomResourceBar scene")
		return

	var reef_viewport_scene := load("res://scenes/layout/ReefViewport.tscn")
	if reef_viewport_scene == null:
		_fail("Failed to load ReefViewport scene")
		return
	var reef_viewport: Node = reef_viewport_scene.instantiate()
	if reef_viewport == null:
		_fail("Failed to instantiate ReefViewport scene")
		return

	var tutorial_overlay: Node = tutorial_overlay_scene.instantiate()
	if tutorial_overlay == null:
		_fail("Failed to instantiate TutorialOverlay scene")
		return

	var expected_defaults := {
		"ResA": "Nutrients: 0",
		"ResB": "Coins: 0",
		"ResC": "Turn: 0/0",
		"ResD": "Reef: 0%",
	}
	for node_name in expected_defaults.keys():
		var label := resource_bar.get_node_or_null("BottomMargin/BottomRow/%s" % node_name) as Label
		if label == null:
			_fail("BottomResourceBar is missing %s" % node_name)
			return
		if label.text != str(expected_defaults[node_name]):
			_fail("%s default text mismatch: expected '%s', got '%s'" % [node_name, str(expected_defaults[node_name]), label.text])
			return
	for button_path in [
		"ReefMargin/ReefLayer/WaterHud/HudMargin/HudVBox/SalinityDialRow/SalinityLowButton",
		"ReefMargin/ReefLayer/WaterHud/HudMargin/HudVBox/SalinityDialRow/SalinityMediumButton",
		"ReefMargin/ReefLayer/WaterHud/HudMargin/HudVBox/SalinityDialRow/SalinityHighButton",
		"ReefMargin/ReefLayer/WaterHud/HudMargin/HudVBox/TempDialRow/TempColdButton",
		"ReefMargin/ReefLayer/WaterHud/HudMargin/HudVBox/TempDialRow/TempModerateButton",
		"ReefMargin/ReefLayer/WaterHud/HudMargin/HudVBox/TempDialRow/TempWarmButton",
	]:
		if reef_viewport.get_node_or_null(button_path) == null:
			_fail("ReefViewport is missing environment dial control %s" % button_path)
			return
	reef_viewport.free()
	resource_bar.free()
	tutorial_overlay.free()
	level_system.free()
	app_controller.free()

	print("Godot content tests passed")
	quit(0)
