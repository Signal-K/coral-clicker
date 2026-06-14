## Scene root that loads IdentifyPhase, handles submit,
## then transitions to GameScreen. This is the entry point from home.
extends Control

const IdentifyPhaseScene := preload("res://scenes/ui/IdentifyPhase.tscn")

var _app: Node

func _ready() -> void:
	_app = get_node_or_null("/root/AppController")
	_launch_identify()

func _launch_identify() -> void:
	var phase: Control = IdentifyPhaseScene.instantiate()
	add_child(phase)

	var subject_path: String = ""
	var species_list: Array = []
	var is_tutorial: bool = false
	var def: Dictionary = {}

	if _app:
		var def_json: String = _app.get_current_level_definition_json()
		if def_json != "":
			var def_variant: Variant = JSON.parse_string(def_json)
			def = def_variant if typeof(def_variant) == TYPE_DICTIONARY else {}

		if def:
			is_tutorial = bool(def.get("is_tutorial", false))
			subject_path = str(def.get("identify_image_path", ""))

		var species_json: String = _app.get_species_reference_json()
		if species_json != "":
			var ref_variant: Variant = JSON.parse_string(species_json)
			var ref: Dictionary = ref_variant if typeof(ref_variant) == TYPE_DICTIONARY else {}
			if ref and not def.is_empty():
				species_list = _build_identify_list(def, ref)

	phase.setup(subject_path, species_list, is_tutorial, def)
	phase.submitted.connect(_on_submitted)

## Build the identify shortlist from the level definition.
## Only species relevant to this level are shown — target coral, positive fish,
## and negative fish (stressors). Each is looked up in the species reference
## to pull in taxonomy, environment, and identification cues.
func _build_identify_list(def: Dictionary, ref: Dictionary) -> Array:
	var all_species: Array = []
	for cat in ["corals", "fish_species", "stressors"]:
		all_species.append_array(Array(ref.get(cat, [])))

	var result: Array = []

	var target_coral: String = str(def.get("target_coral", ""))
	if not target_coral.is_empty():
		var entry: Dictionary = _find_by_name(target_coral, all_species)
		entry["role"] = "coral"
		entry["category"] = "coral"
		result.append(entry)

	for fish_name in def.get("positive_fish", []):
		var entry: Dictionary = _find_by_name(str(fish_name), all_species)
		entry["role"] = "fish"
		entry["category"] = "fish"
		result.append(entry)

	for fish_name in def.get("negative_fish", []):
		var entry: Dictionary = _find_by_name(str(fish_name), all_species)
		entry["role"] = "stressor"
		entry["category"] = "stressor"
		result.append(entry)

	return result

func _find_by_name(target: String, pool: Array) -> Dictionary:
	var lower: String = target.to_lower()
	for sp in pool:
		if typeof(sp) != TYPE_DICTIONARY:
			continue
		if str(sp.get("name", "")).to_lower() == lower:
			return sp.duplicate()
		if str(sp.get("common_name", "")).to_lower() == lower:
			return sp.duplicate()
	return {"name": target}

func _on_submitted(selected: Array[String]) -> void:
	if _app:
		var def_json: String = _app.get_current_level_definition_json()
		if def_json != "":
			var def_variant: Variant = JSON.parse_string(def_json)
			var def: Dictionary = def_variant if typeof(def_variant) == TYPE_DICTIONARY else {}
			if def:
				var subject_id: String = str(def.get("subject_id", ""))
				for sid in selected:
					_app.queue_offline_classification(subject_id, sid, sid)
	_go_to_game()

func _go_to_game() -> void:
	get_tree().change_scene_to_file("res://scenes/layout/GameScreen.tscn")
