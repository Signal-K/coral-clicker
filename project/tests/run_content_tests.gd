extends SceneTree

func _fail(message: String) -> void:
	printerr(message)
	quit(1)

func _init() -> void:
	var levels_path := "res://data/starter_levels.json"
	var species_path := "res://data/species_reference.json"

	if not FileAccess.file_exists(levels_path):
		_fail("Missing starter levels JSON")
		return
	if not FileAccess.file_exists(species_path):
		_fail("Missing species reference JSON")
		return

	var levels_doc = JSON.parse_string(FileAccess.get_file_as_string(levels_path))
	if typeof(levels_doc) != TYPE_DICTIONARY:
		_fail("starter_levels.json is not a dictionary")
		return

	var levels: Array = levels_doc.get("levels", [])
	if levels.size() != 10:
		_fail("Expected 10 levels, got %d" % levels.size())
		return

	for idx in range(levels.size()):
		var level: Dictionary = levels[idx]
		var level_id := int(level.get("id", idx + 1))

		# Required fields
		if not level.has("target_composition") or not level.has("starting_fishfood") or not level.has("reward_fishfood"):
			_fail("Level %d missing required fields (target_composition, starting_fishfood, reward_fishfood)" % level_id)
			return
		if typeof(level.get("target_composition")) != TYPE_DICTIONARY or level["target_composition"].is_empty():
			_fail("Level %d target_composition must be a non-empty dictionary" % level_id)
			return
		if not level.has("match_threshold"):
			_fail("Level %d missing match_threshold" % level_id)
			return
		if not level.has("zone") or str(level.get("zone", "")).is_empty():
			_fail("Level %d missing zone" % level_id)
			return
		if not level.has("available_fish"):
			_fail("Level %d missing available_fish" % level_id)
			return
		if not level.has("placement_constraints"):
			_fail("Level %d missing placement_constraints" % level_id)
			return

	var species_doc = JSON.parse_string(FileAccess.get_file_as_string(species_path))
	if typeof(species_doc) != TYPE_DICTIONARY:
		_fail("species_reference.json is not a dictionary")
		return
	if species_doc.get("corals", []).size() < 12:
		_fail("Expected at least 12 coral entries")
		return

	var fish_list: Array = species_doc.get("fish_species", [])
	if fish_list.size() < 5:
		_fail("Expected at least 5 fish species entries")
		return

	# Validate each fish has production rules
	for fish in fish_list:
		var name := str(fish.get("name", ""))
		if not fish.has("produces") or typeof(fish.get("produces")) != TYPE_DICTIONARY:
			_fail("Fish '%s' missing produces dictionary" % name)
			return
		if not fish.has("produces_rate"):
			_fail("Fish '%s' missing produces_rate" % name)
			return

	var stressor_list: Array = species_doc.get("stressors", [])
	for stressor in stressor_list:
		var name := str(stressor.get("name", ""))
		if not stressor.has("suppresses_rate"):
			_fail("Stressor '%s' missing suppresses_rate" % name)
			return

	var app_controller_script = load("res://app_controller.gd")
	var app_controller = app_controller_script.new()
	app_controller._load_content_data()

	var loaded_levels = JSON.parse_string(app_controller.get_puzzle_levels_json())
	if typeof(loaded_levels) != TYPE_ARRAY or loaded_levels.size() != 10:
		_fail("AppController did not expose 10 levels")
		return

	var loaded_species = JSON.parse_string(app_controller.get_species_reference_json())
	if typeof(loaded_species) != TYPE_DICTIONARY:
		_fail("AppController did not expose species reference")
		return

	var state = JSON.parse_string(app_controller.get_level_state_json())
	if typeof(state) != TYPE_DICTIONARY:
		_fail("AppController state JSON is invalid")
		return

	# Verify level 1 definition has the new format
	var level_def = state.get("current_level_definition", {})
	if typeof(level_def) != TYPE_DICTIONARY or not level_def.has("target_composition"):
		_fail("Level 1 definition missing target_composition in state")
		return

	print("Godot content tests passed")
	quit(0)
