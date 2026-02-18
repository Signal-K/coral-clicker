extends Node

signal level_progress_changed(payload_json: String)
signal supabase_sync_status(payload_json: String)

const LEVEL_COUNT := 10
const STARTER_LEVELS_PATH := "res://data/starter_levels.json"
const SPECIES_REFERENCE_PATH := "res://data/species_reference.json"

var _supabase_url: String = "http://127.0.0.1:54321"
var _supabase_anon_key: String = "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH"
var _supabase_table: String = "player_progress"
var _player_id: String = "local-player"

var _pending_request_kind := ""
var _levels: Array = []
var _species_reference: Dictionary = {}
var _base_carryover_fishfood := 20

var state := {
	"current_level": 1,
	"completed_levels": [],
	"rewards_total": 0,
	"last_reward": 0,
	"carryover_fishfood": 20,
	"updated_at": "",
}

@onready var _http := HTTPRequest.new()

func _ready() -> void:
	_load_content_data()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)
	_emit_state()

func _load_content_data() -> void:
	var levels_raw: Variant = _read_json_file(STARTER_LEVELS_PATH)
	if typeof(levels_raw) == TYPE_DICTIONARY:
		var levels: Array = levels_raw.get("levels", [])
		if typeof(levels) == TYPE_ARRAY and not levels.is_empty():
			_levels = levels
			_base_carryover_fishfood = int(levels_raw.get("economy", {}).get("starting_carryover_fishfood", 20))

	var species_raw: Variant = _read_json_file(SPECIES_REFERENCE_PATH)
	if typeof(species_raw) == TYPE_DICTIONARY:
		_species_reference = species_raw

	state["carryover_fishfood"] = _base_carryover_fishfood

func _read_json_file(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed == null:
		return {}
	return parsed

#region Level System API
func get_level_state_json() -> String:
	return JSON.stringify(_sanitized_state())


func get_puzzle_levels_json() -> String:
	return JSON.stringify(_levels)


func get_current_level_definition_json() -> String:
	return JSON.stringify(_get_level_definition(int(state.get("current_level", 1))))


func get_species_reference_json() -> String:
	return JSON.stringify(_species_reference)


func emit_level_state() -> void:
	_emit_state()


func select_level(level_number: int) -> bool:
	if level_number < 1 or level_number > LEVEL_COUNT:
		return false
	if level_number > _max_unlocked_level():
		return false
	state["current_level"] = level_number
	_touch_state()
	_emit_state()
	return true


func complete_current_level(reward: int = 100) -> Dictionary:
	var current_level := int(state.get("current_level", 1))
	var completed_levels: Array = state.get("completed_levels", []).duplicate(true)
	if not completed_levels.has(current_level):
		completed_levels.append(current_level)
		completed_levels.sort()
		state["completed_levels"] = completed_levels

	var level_def: Dictionary = _get_level_definition(current_level)
	var configured_reward := int(level_def.get("reward_fishfood", reward))
	state["last_reward"] = configured_reward
	state["rewards_total"] = int(state.get("rewards_total", 0)) + configured_reward
	state["carryover_fishfood"] = int(state.get("carryover_fishfood", _base_carryover_fishfood)) + configured_reward
	state["current_level"] = min(current_level + 1, LEVEL_COUNT)
	_touch_state()
	_emit_state()
	return _sanitized_state()


func set_level_state_json(raw_json: String) -> bool:
	var parsed = JSON.parse_string(raw_json)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	_apply_external_state(parsed)
	_emit_state()
	return true


func set_external_message(raw_json: String) -> bool:
	var parsed = JSON.parse_string(raw_json)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	var action: String = str(parsed.get("action", ""))
	match action:
		"select_level":
			return select_level(int(parsed.get("level", 1)))
		"complete_level":
			complete_current_level(int(parsed.get("reward", 100)))
			return true
		"set_state":
			_apply_external_state(parsed.get("state", {}))
			_emit_state()
			return true
		"sync_to_supabase":
			sync_progress_to_supabase()
			return true
		"load_from_supabase":
			load_progress_from_supabase()
			return true
		_:
			return false


func get_ui_template_json() -> String:
	var template := {
		"title": "Coral",
		"theme": "deep_sea",
		"actions": [
			"select_level",
			"complete_level",
			"sync_to_supabase",
			"load_from_supabase"
		]
	}
	return JSON.stringify(template)

#endregion

#region Supabase
func set_supabase_config(url: String, anon_key: String, table_name: String = "player_progress", player_id: String = "local-player") -> void:
	_supabase_url = url.rstrip("/")
	_supabase_anon_key = anon_key
	_supabase_table = table_name
	_player_id = player_id


func sync_progress_to_supabase() -> bool:
	if _supabase_url.is_empty() or _supabase_anon_key.is_empty():
		_emit_sync_status("error", "Missing Supabase config")
		return false
	if _http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_emit_sync_status("busy", "A request is already in progress")
		return false

	_pending_request_kind = "sync"
	var url := "%s/rest/v1/%s?on_conflict=player_id" % [_supabase_url, _supabase_table]
	var payload := [
		{
			"player_id": _player_id,
			"current_level": int(state.get("current_level", 1)),
			"completed_levels": state.get("completed_levels", []),
			"rewards_total": int(state.get("rewards_total", 0)),
			"metadata": {
				"updated_at": str(state.get("updated_at", "")),
				"last_reward": int(state.get("last_reward", 0)),
				"carryover_fishfood": int(state.get("carryover_fishfood", _base_carryover_fishfood)),
			},
		}
	]
	var body := JSON.stringify(payload)
	var headers := [
		"apikey: %s" % _supabase_anon_key,
		"Authorization: Bearer %s" % _supabase_anon_key,
		"Content-Type: application/json",
		"Prefer: return=representation,resolution=merge-duplicates"
	]
	var err := _http.request(url, headers, HTTPClient.METHOD_POST, body)
	if err != OK:
		_emit_sync_status("error", "Failed to start sync request")
	return err == OK


func load_progress_from_supabase() -> bool:
	if _supabase_url.is_empty() or _supabase_anon_key.is_empty():
		_emit_sync_status("error", "Missing Supabase config")
		return false
	if _http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_emit_sync_status("busy", "A request is already in progress")
		return false

	_pending_request_kind = "load"
	var url := "%s/rest/v1/%s?player_id=eq.%s&select=player_id,current_level,completed_levels,rewards_total,metadata" % [_supabase_url, _supabase_table, _player_id.uri_encode()]
	var headers := [
		"apikey: %s" % _supabase_anon_key,
		"Authorization: Bearer %s" % _supabase_anon_key,
		"Accept: application/json"
	]
	var err := _http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		_emit_sync_status("error", "Failed to start load request")
	return err == OK


func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var text := body.get_string_from_utf8()
	if response_code < 200 or response_code > 299:
		_emit_sync_status("error", "Supabase request failed", response_code, text)
		_pending_request_kind = ""
		return

	if _pending_request_kind == "load":
		_apply_loaded_response(text)
		_emit_state()
		_emit_sync_status("ok", "Loaded progress from Supabase", response_code, text)
	elif _pending_request_kind == "sync":
		_emit_sync_status("ok", "Synced progress to Supabase", response_code, text)
	else:
		_emit_sync_status("ok", "Request completed", response_code, text)

	_pending_request_kind = ""


func _apply_loaded_response(response_text: String) -> void:
	var parsed = JSON.parse_string(response_text)
	if typeof(parsed) != TYPE_ARRAY:
		return
	if parsed.size() == 0:
		return
	var row = parsed[0]
	if typeof(row) != TYPE_DICTIONARY:
		return

	var metadata: Dictionary = row.get("metadata", {})
	var incoming := {
		"current_level": int(row.get("current_level", 1)),
		"completed_levels": row.get("completed_levels", []),
		"rewards_total": int(row.get("rewards_total", 0)),
		"last_reward": int(metadata.get("last_reward", 0)),
		"carryover_fishfood": int(metadata.get("carryover_fishfood", _base_carryover_fishfood)),
		"updated_at": str(metadata.get("updated_at", "")),
	}
	_apply_external_state(incoming)

#endregion

#region Helpers
func _get_level_definition(level_number: int) -> Dictionary:
	if level_number <= 0:
		return {}
	for level in _levels:
		if int(level.get("id", -1)) == level_number:
			return level
	return {}


func _get_level_available_fishfood(level_number: int) -> int:
	var level_def: Dictionary = _get_level_definition(level_number)
	var base := int(level_def.get("starting_fishfood", 0))
	var carry := int(state.get("carryover_fishfood", _base_carryover_fishfood))
	return base + carry


func _apply_external_state(incoming: Dictionary) -> void:
	var completed_levels: Array = []
	var incoming_completed: Variant = incoming.get("completed_levels", [])
	if typeof(incoming_completed) == TYPE_ARRAY:
		for level in incoming_completed:
			var casted := int(level)
			if casted >= 1 and casted <= LEVEL_COUNT and not completed_levels.has(casted):
				completed_levels.append(casted)
	completed_levels.sort()

	state["completed_levels"] = completed_levels
	state["current_level"] = clampi(int(incoming.get("current_level", 1)), 1, LEVEL_COUNT)
	state["rewards_total"] = maxi(0, int(incoming.get("rewards_total", 0)))
	state["last_reward"] = maxi(0, int(incoming.get("last_reward", 0)))
	state["carryover_fishfood"] = maxi(0, int(incoming.get("carryover_fishfood", _base_carryover_fishfood)))
	_touch_state()


func _touch_state() -> void:
	state["updated_at"] = Time.get_datetime_string_from_system(true)


func _max_unlocked_level() -> int:
	var completed_levels: Array = state.get("completed_levels", [])
	if completed_levels.is_empty():
		return 1
	return mini(LEVEL_COUNT, int(completed_levels.max()) + 1)


func _sanitized_state() -> Dictionary:
	var current_level := int(state.get("current_level", 1))
	return {
		"player_id": _player_id,
		"current_level": current_level,
		"completed_levels": state.get("completed_levels", []).duplicate(true),
		"rewards_total": int(state.get("rewards_total", 0)),
		"last_reward": int(state.get("last_reward", 0)),
		"carryover_fishfood": int(state.get("carryover_fishfood", _base_carryover_fishfood)),
		"current_level_available_fishfood": _get_level_available_fishfood(current_level),
		"current_level_definition": _get_level_definition(current_level),
		"updated_at": str(state.get("updated_at", "")),
		"level_count": LEVEL_COUNT,
		"max_unlocked_level": _max_unlocked_level(),
	}


func _emit_state() -> void:
	level_progress_changed.emit(JSON.stringify(_sanitized_state()))


func _emit_sync_status(kind: String, message: String, code: int = 0, raw: String = "") -> void:
	var payload := {
		"kind": kind,
		"message": message,
		"code": code,
		"raw": raw,
	}
	supabase_sync_status.emit(JSON.stringify(payload))

#endregion
