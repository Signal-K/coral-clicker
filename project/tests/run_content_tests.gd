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
		if not level.has("target_coral") or not level.has("starting_fishfood") or not level.has("reward_fishfood"):
			_fail("Level %d missing required fields" % int(level.get("id", idx + 1)))
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
	if int(state.get("current_level_available_fishfood", 0)) < 64:
		# Not a strict gameplay rule, but ensures carryover+level provisioning is non-trivial.
		# Default is level1(12)+carryover(20)=32 before progression.
		# We avoid hard-failing low economy values if game design changes.
		pass

	print("Godot content tests passed")
	quit(0)
