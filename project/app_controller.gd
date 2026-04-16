extends Node

signal level_progress_changed(payload_json: String)
signal supabase_sync_status(payload_json: String)

const LEVEL_COUNT := 10
const STARTER_LEVELS_PATH := "res://data/starter_levels.json"
const SPECIES_REFERENCE_PATH := "res://data/species_reference.json"
const CLICK_A_CORAL_DATA_PATH := "res://data/click_a_coral_subjects.json"
const SAVE_PATH := "user://save.json"
const PENDING_CLASSIFICATIONS_PATH := "user://pending_classifications.json"
const SUBJECT_CACHE_DIR := "user://subject_cache"
const CONFIG_PATH := "res://data/config.json"

# Defaults point to local Supabase dev instance.
# Override any of these in res://data/config.json for production builds.
var _supabase_url: String = "http://127.0.0.1:54321"
var _supabase_anon_key: String = "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH"
var _supabase_table: String = "player_progress"
var _player_id: String = "local-player"

var _pending_request_kind := ""
var _pending_asset_subject_id := ""
var _levels: Array = []
var _species_reference: Dictionary = {}
var _subject_entries_by_id: Dictionary = {}
var _asset_prefetch_queue: Array[String] = []

var state := {
	"current_level": 1,
	"completed_levels": [],
	"global_coins": 0,
	"carryover_triggers": 0,
	"last_coins_earned": 0,
	"pending_rewards": [],
	"classification_bonus_total": 0,
	"unlocked_corals": [],
	"classification_history": [],
	"pending_offline_classifications": [],
	"tutorial_complete": false,
	"stressor_tooltip_shown": {},
	"updated_at": "",
	"tank": {
		"fish_populations": {
			"Blue Chromis": 3,
			"Sergeant Major": 2
		},
		"coral_population": 4,
		"target_coral": "Madracis Sp.",
		"last_collect_timestamp": 0,
		"accumulated_coins": 0,
	},
}

@onready var _http := HTTPRequest.new()
@onready var _asset_http := HTTPRequest.new()

func _ready() -> void:
	_load_env_config()
	_load_content_data()
	add_child(_http)
	add_child(_asset_http)
	_http.request_completed.connect(_on_request_completed)
	_asset_http.request_completed.connect(_on_asset_request_completed)
	_load_local_state()
	_emit_state()
	
	var sync_timer := Timer.new()
	sync_timer.wait_time = 60.0
	sync_timer.timeout.connect(_retry_online_work)
	add_child(sync_timer)
	sync_timer.start()

	call_deferred("_retry_online_work")


func _load_env_config() -> void:
	var cfg: Variant = _read_json_file(CONFIG_PATH)
	if typeof(cfg) != TYPE_DICTIONARY:
		return
	var url: Variant = cfg.get("supabase_url", "")
	if typeof(url) == TYPE_STRING and not (url as String).is_empty():
		_supabase_url = url
	var key: Variant = cfg.get("supabase_anon_key", "")
	if typeof(key) == TYPE_STRING and not (key as String).is_empty():
		_supabase_anon_key = key
	var table: Variant = cfg.get("supabase_table", "")
	if typeof(table) == TYPE_STRING and not (table as String).is_empty():
		_supabase_table = table
	var pid: Variant = cfg.get("player_id", "")
	if typeof(pid) == TYPE_STRING and not (pid as String).is_empty():
		_player_id = pid

func _load_content_data() -> void:
	var levels_raw: Variant = _read_json_file(STARTER_LEVELS_PATH)
	if typeof(levels_raw) == TYPE_DICTIONARY:
		var levels: Array = levels_raw.get("levels", [])
		if typeof(levels) == TYPE_ARRAY and not levels.is_empty():
			_levels = levels

	var species_raw: Variant = _read_json_file(SPECIES_REFERENCE_PATH)
	if typeof(species_raw) == TYPE_DICTIONARY:
		_species_reference = species_raw

	var subjects_raw: Variant = _read_json_file(CLICK_A_CORAL_DATA_PATH)
	if typeof(subjects_raw) == TYPE_DICTIONARY:
		var entries: Variant = subjects_raw.get("entries", [])
		if typeof(entries) == TYPE_ARRAY:
			for entry in entries:
				if typeof(entry) != TYPE_DICTIONARY:
					continue
				var subject_id := str(entry.get("subject_id", ""))
				if subject_id.is_empty():
					continue
				_subject_entries_by_id[subject_id] = entry

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


func _write_json_file(path: String, value: Variant) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(value))


func _load_local_state() -> void:
	var saved: Variant = _read_json_file(SAVE_PATH)
	if typeof(saved) == TYPE_DICTIONARY:
		_apply_external_state(saved)
	var pending: Variant = _read_json_file(PENDING_CLASSIFICATIONS_PATH)
	if typeof(pending) == TYPE_ARRAY:
		state["pending_offline_classifications"] = pending


func _persist_local_state() -> void:
	_write_json_file(SAVE_PATH, state)


func _persist_pending_classifications() -> void:
	_write_json_file(PENDING_CLASSIFICATIONS_PATH, state.get("pending_offline_classifications", []))


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		call_deferred("_retry_online_work")

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
	if level_number == 1 and not is_tutorial_complete():
		state["current_level"] = 0
		_touch_state()
		_emit_state()
		return true
	state["current_level"] = level_number
	_touch_state()
	_emit_state()
	return true


func complete_current_level(coins_earned: int = 0) -> Dictionary:
	var current_level := int(state.get("current_level", 1))
	if current_level == 0:
		var tutorial_reward := maxi(0, coins_earned)
		if tutorial_reward > 0:
			state["global_coins"] = int(state.get("global_coins", 0)) + tutorial_reward
			state["last_coins_earned"] = tutorial_reward
		state["tutorial_complete"] = true
		state["current_level"] = 1
		_touch_state()
		_emit_state()
		return _sanitized_state()
	var completed_levels: Array = state.get("completed_levels", []).duplicate(true)
	if not completed_levels.has(current_level):
		completed_levels.append(current_level)
		completed_levels.sort()
		state["completed_levels"] = completed_levels

	var awarded_coins := maxi(0, coins_earned)
	if awarded_coins > 0:
		var pending_rewards: Array = state.get("pending_rewards", []).duplicate(true)
		pending_rewards.append({
			"level": current_level,
			"coins": awarded_coins,
			"synced": false,
			"timestamp": Time.get_datetime_string_from_system(true),
		})
		state["pending_rewards"] = pending_rewards
	state["last_coins_earned"] = 0
	state["current_level"] = min(current_level + 1, LEVEL_COUNT)
	_touch_state()
	sync_progress_to_supabase()
	_emit_state()
	return _sanitized_state()


func add_coins(amount: int) -> void:
	state["global_coins"] = int(state.get("global_coins", 0)) + maxi(0, amount)
	_touch_state()
	_emit_state()


func get_carryover_triggers() -> int:
	return maxi(0, int(state.get("carryover_triggers", 0)))


func add_carryover_triggers(amount: int) -> void:
	if amount <= 0:
		return
	state["carryover_triggers"] = get_carryover_triggers() + amount
	_touch_state()
	_emit_state()


func consume_carryover_triggers(amount: int) -> int:
	var available := get_carryover_triggers()
	var spent := mini(available, maxi(0, amount))
	if spent <= 0:
		return 0
	state["carryover_triggers"] = available - spent
	_touch_state()
	_emit_state()
	return spent


func spend_coins(amount: int) -> bool:
	var current := int(state.get("global_coins", 0))
	if current < amount:
		return false
	state["global_coins"] = current - amount
	_touch_state()
	_emit_state()
	return true


func get_coins() -> int:
	return int(state.get("global_coins", 0))


func get_pending_reward_total() -> int:
	var pending_rewards: Variant = state.get("pending_rewards", [])
	if typeof(pending_rewards) != TYPE_ARRAY:
		return 0
	var total := 0
	for reward in pending_rewards:
		if typeof(reward) == TYPE_DICTIONARY:
			total += maxi(0, int(reward.get("coins", 0)))
	return total


func is_tutorial_complete() -> bool:
	return bool(state.get("tutorial_complete", false))


func set_tutorial_complete(completed: bool) -> void:
	state["tutorial_complete"] = completed
	_touch_state()
	_emit_state()


func has_seen_stressor_tooltip(stressor_id: String) -> bool:
	var shown: Variant = state.get("stressor_tooltip_shown", {})
	if typeof(shown) != TYPE_DICTIONARY:
		return false
	return bool(shown.get(stressor_id, false))


func mark_stressor_tooltip_shown(stressor_id: String) -> void:
	var shown: Dictionary = state.get("stressor_tooltip_shown", {}).duplicate(true)
	shown[stressor_id] = true
	state["stressor_tooltip_shown"] = shown
	_touch_state()
	_emit_state()


func submit_post_level_classification(
	subject_id: String,
	canonical_name: String,
	guessed_name: String,
	accepted_answers: Array = [],
	bonus_coins: int = 5
) -> Dictionary:
	var normalized_guess := _normalize_label(guessed_name)
	var normalized_canonical := _normalize_label(canonical_name)
	var normalized_answers: Array[String] = [normalized_canonical]

	for answer in accepted_answers:
		var normalized := _normalize_label(str(answer))
		if not normalized.is_empty() and not normalized_answers.has(normalized):
			normalized_answers.append(normalized)

	var is_correct := normalized_answers.has(normalized_guess)
	var bonus := bonus_coins if is_correct else 0

	if is_correct:
		state["global_coins"] = int(state.get("global_coins", 0)) + bonus
		state["classification_bonus_total"] = int(state.get("classification_bonus_total", 0)) + bonus
		var unlocked_corals: Array = to_string_array(state.get("unlocked_corals", []))
		if not unlocked_corals.has(canonical_name):
			unlocked_corals.append(canonical_name)
		state["unlocked_corals"] = unlocked_corals

	var history: Array = state.get("classification_history", []).duplicate(true)
	history.append({
		"subject_id": subject_id,
		"canonical_name": canonical_name,
		"guessed_name": guessed_name,
		"accepted_answers": accepted_answers.duplicate(true),
		"correct": is_correct,
		"bonus": bonus,
		"level_completed": maxi(1, int(state.get("current_level", 1)) - 1),
		"timestamp": Time.get_datetime_string_from_system(true),
	})
	if history.size() > 100:
		history = history.slice(history.size() - 100, history.size())
	state["classification_history"] = history

	_touch_state()
	_emit_state()
	return {
		"correct": is_correct,
		"bonus": bonus,
		"subject_id": subject_id,
		"canonical_name": canonical_name,
		"guessed_name": guessed_name,
		"accepted_answers": accepted_answers.duplicate(true),
		"unlocked_corals": state.get("unlocked_corals", []).duplicate(true),
	}


#region Tank (Sandbox Hub)
func get_tank_state_json() -> String:
	return JSON.stringify(_get_tank())


func get_tank_pending_coins() -> int:
	var tank := _get_tank()
	var last_collect := int(tank.get("last_collect_timestamp", 0))
	if last_collect == 0:
		return 0
	var now := int(Time.get_unix_time_from_system())
	var elapsed_seconds := now - last_collect
	var elapsed_hours := float(elapsed_seconds) / 3600.0

	var fish_pops: Dictionary = tank.get("fish_populations", {})
	var fish_total := 0
	for species in fish_pops.keys():
		fish_total += int(fish_pops[species])

	var coral_pop := int(tank.get("coral_population", 0))
	# Rate: 1 coin per coral per hour + 0.3 coins per fish per hour
	var rate_per_hour := float(coral_pop) * 1.0 + float(fish_total) * 0.3
	return int(floor(rate_per_hour * elapsed_hours)) + int(tank.get("accumulated_coins", 0))


func collect_tank_rewards() -> int:
	var pending := get_tank_pending_coins()
	if pending > 0:
		state["global_coins"] = int(state.get("global_coins", 0)) + pending
	var tank := _get_tank().duplicate(true)
	tank["last_collect_timestamp"] = int(Time.get_unix_time_from_system())
	tank["accumulated_coins"] = 0
	state["tank"] = tank
	_touch_state()
	_emit_state()
	return pending


func start_tank_timer() -> void:
	var tank := _get_tank().duplicate(true)
	if int(tank.get("last_collect_timestamp", 0)) == 0:
		tank["last_collect_timestamp"] = int(Time.get_unix_time_from_system())
		state["tank"] = tank
		_touch_state()


func update_tank_population(species: String, delta: int) -> void:
	var tank := _get_tank().duplicate(true)
	var pops: Dictionary = tank.get("fish_populations", {}).duplicate(true)
	var current := int(pops.get(species, 0))
	var next_val := maxi(0, current + delta)
	if next_val == 0:
		pops.erase(species)
	else:
		pops[species] = next_val
	tank["fish_populations"] = pops
	state["tank"] = tank
	_touch_state()
	_emit_state()


func set_tank_coral(coral_name: String, population: int) -> void:
	var tank := _get_tank().duplicate(true)
	tank["target_coral"] = coral_name
	tank["coral_population"] = maxi(0, population)
	state["tank"] = tank
	_touch_state()
	_emit_state()


func _get_tank() -> Dictionary:
	var tank: Variant = state.get("tank", null)
	if typeof(tank) == TYPE_DICTIONARY:
		return tank
	return {
		"fish_populations": {"Blue Chromis": 3, "Sergeant Major": 2},
		"coral_population": 4,
		"target_coral": "Madracis Sp.",
		"last_collect_timestamp": 0,
		"accumulated_coins": 0,
	}
#endregion


func queue_offline_classification(
	subject_id: String,
	canonical_name: String,
	guessed_name: String
) -> void:
	var queue: Array = state.get("pending_offline_classifications", []).duplicate(true)
	queue.append({
		"subject_id": subject_id,
		"canonical_name": canonical_name,
		"guessed_name": guessed_name,
		"timestamp": Time.get_datetime_string_from_system(true),
	})
	state["pending_offline_classifications"] = queue
	_touch_state()
	sync_progress_to_supabase()


func flush_offline_classifications() -> void:
	var queue: Array = state.get("pending_offline_classifications", []).duplicate(true)
	if queue.is_empty():
		return
	sync_progress_to_supabase()


func get_cached_subject_image_path(subject_id: String) -> String:
	if subject_id.is_empty():
		return ""
	var entry: Dictionary = _subject_entries_by_id.get(subject_id, {})
	if entry.is_empty():
		return ""
	var image_url := str(entry.get("image_url", ""))
	var ext := image_url.get_extension().to_lower()
	if ext.is_empty():
		ext = "jpg"
	return "%s/%s.%s" % [SUBJECT_CACHE_DIR, subject_id, ext]


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
			complete_current_level(int(parsed.get("coins_earned", 0)))
			return true
		"add_coins":
			add_coins(int(parsed.get("amount", 0)))
			return true
		"spend_coins":
			return spend_coins(int(parsed.get("amount", 0)))
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
		"prefetch_subject_images":
			prefetch_unlocked_subject_images()
			return true
		"flush_offline_classifications":
			flush_offline_classifications()
			return true
		"classify_post_level":
			var payload: Dictionary = parsed.get("payload", {})
			if typeof(payload) != TYPE_DICTIONARY:
				return false
			submit_post_level_classification(
				str(payload.get("subject_id", "")),
				str(payload.get("canonical_name", "")),
				str(payload.get("guessed_name", "")),
				payload.get("accepted_answers", []),
				int(payload.get("bonus_coins", 5))
			)
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
	if _http == null:
		_emit_sync_status("error", "HTTP client unavailable")
		return false
	if _http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		_emit_sync_status("busy", "A request is already in progress")
		return false

	var projected_coins := int(state.get("global_coins", 0)) + get_pending_reward_total()
	_pending_request_kind = "sync"
	var url := "%s/rest/v1/%s?on_conflict=player_id" % [_supabase_url, _supabase_table]
	var payload := [
		{
			"player_id": _player_id,
			"current_level": int(state.get("current_level", 1)),
			"completed_levels": state.get("completed_levels", []),
			"rewards_total": projected_coins,
			"metadata": {
				"updated_at": str(state.get("updated_at", "")),
				"global_coins": projected_coins,
				"carryover_triggers": get_carryover_triggers(),
				"last_coins_earned": int(state.get("last_coins_earned", 0)),
				"pending_rewards": state.get("pending_rewards", []).duplicate(true),
				"classification_bonus_total": int(state.get("classification_bonus_total", 0)),
				"unlocked_corals": state.get("unlocked_corals", []).duplicate(true),
				"classification_history": state.get("classification_history", []).duplicate(true),
				"pending_offline_classifications": state.get("pending_offline_classifications", []).duplicate(true),
				"tutorial_complete": bool(state.get("tutorial_complete", false)),
				"stressor_tooltip_shown": state.get("stressor_tooltip_shown", {}).duplicate(true),
				"tank": _get_tank().duplicate(true),
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


func prefetch_unlocked_subject_images() -> void:
	var max_unlocked := _max_unlocked_level()
	for level in _levels:
		if typeof(level) != TYPE_DICTIONARY:
			continue
		var level_id := int(level.get("id", 0))
		if level_id <= 0 or level_id > max_unlocked:
			continue
		var subject_id := str(level.get("subject_id", ""))
		if subject_id.is_empty():
			continue
		var cache_path := get_cached_subject_image_path(subject_id)
		if cache_path.is_empty() or FileAccess.file_exists(cache_path) or _asset_prefetch_queue.has(subject_id):
			continue
		_asset_prefetch_queue.append(subject_id)
	_start_next_asset_prefetch()


func load_progress_from_supabase() -> bool:
	if _supabase_url.is_empty() or _supabase_anon_key.is_empty():
		_emit_sync_status("error", "Missing Supabase config")
		return false
	if _http == null:
		_emit_sync_status("error", "HTTP client unavailable")
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


func _retry_online_work() -> void:
	prefetch_unlocked_subject_images()
	if not state.get("pending_offline_classifications", []).is_empty() or get_pending_reward_total() > 0:
		sync_progress_to_supabase()


func _start_next_asset_prefetch() -> void:
	if _asset_http == null:
		return
	if _asset_http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		return
	if _asset_prefetch_queue.is_empty():
		return
	_pending_asset_subject_id = _asset_prefetch_queue.pop_front()
	var entry: Dictionary = _subject_entries_by_id.get(_pending_asset_subject_id, {})
	var image_url := str(entry.get("image_url", ""))
	if image_url.is_empty():
		_pending_asset_subject_id = ""
		_start_next_asset_prefetch()
		return
	var err := _asset_http.request(image_url)
	if err != OK:
		_pending_asset_subject_id = ""
		_start_next_asset_prefetch()


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
		var applied_reward_total := get_pending_reward_total()
		state["global_coins"] = int(state.get("global_coins", 0)) + applied_reward_total
		state["last_coins_earned"] = applied_reward_total
		state["pending_rewards"] = []
		state["pending_offline_classifications"] = []
		_touch_state()
		_emit_state()
		_emit_sync_status("ok", "Synced progress to Supabase", response_code, text)
	else:
		_emit_sync_status("ok", "Request completed", response_code, text)

	_pending_request_kind = ""


func _on_asset_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code >= 200 and response_code <= 299 and not _pending_asset_subject_id.is_empty():
		DirAccess.make_dir_recursive_absolute(SUBJECT_CACHE_DIR)
		var cache_path := get_cached_subject_image_path(_pending_asset_subject_id)
		if not cache_path.is_empty():
			var file := FileAccess.open(cache_path, FileAccess.WRITE)
			if file != null:
				file.store_buffer(body)
	_pending_asset_subject_id = ""
	_start_next_asset_prefetch()


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
		"global_coins": int(metadata.get("global_coins", row.get("rewards_total", 0))),
		"carryover_triggers": int(metadata.get("carryover_triggers", 0)),
		"last_coins_earned": int(metadata.get("last_coins_earned", 0)),
		"pending_rewards": metadata.get("pending_rewards", []),
		"classification_bonus_total": int(metadata.get("classification_bonus_total", 0)),
		"unlocked_corals": metadata.get("unlocked_corals", []),
		"classification_history": metadata.get("classification_history", []),
		"pending_offline_classifications": metadata.get("pending_offline_classifications", []),
		"tutorial_complete": bool(metadata.get("tutorial_complete", false)),
		"stressor_tooltip_shown": metadata.get("stressor_tooltip_shown", {}),
		"tank": metadata.get("tank", {}),
		"updated_at": str(metadata.get("updated_at", "")),
	}
	_apply_external_state(incoming)

#endregion

#region Helpers
func _get_level_definition(level_number: int) -> Dictionary:
	if level_number == 0:
		return {
			"id": 0,
			"name": "Tutorial Mission",
			"is_tutorial": true,
			"target_coral": "Madracis Sp.",
			"target_population": 5,
			"turn_limit": 10,
			"population_cap": 5,
			"starting_nutrients": 18,
			"positive_fish": ["Blue Chromis"],
			"negative_fish": [],
			"starting_fish": {"Blue Chromis": 2},
			"reward_coins": 20,
			"subject_id": "tutorial-madracis",
			"identify_image_path": "",
			"breeding_interval_min": 2.0,
			"breeding_interval_max": 4.0
		}
	if level_number <= 0:
		return {}
	for level in _levels:
		if int(level.get("id", -1)) == level_number:
			return level
	return {}


func _get_level_available_nutrients(level_number: int) -> int:
	var level_def: Dictionary = _get_level_definition(level_number)
	return int(level_def.get("starting_nutrients", 10))


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
	state["current_level"] = clampi(int(incoming.get("current_level", 1)), 0, LEVEL_COUNT)
	state["global_coins"] = maxi(0, int(incoming.get("global_coins", 0)))
	state["carryover_triggers"] = maxi(0, int(incoming.get("carryover_triggers", 0)))
	state["last_coins_earned"] = maxi(0, int(incoming.get("last_coins_earned", 0)))
	var incoming_pending_rewards: Variant = incoming.get("pending_rewards", [])
	var pending_rewards: Array = []
	if typeof(incoming_pending_rewards) == TYPE_ARRAY:
		for reward in incoming_pending_rewards:
			if typeof(reward) == TYPE_DICTIONARY:
				pending_rewards.append(reward)
	state["pending_rewards"] = pending_rewards
	state["classification_bonus_total"] = maxi(0, int(incoming.get("classification_bonus_total", 0)))
	state["unlocked_corals"] = to_string_array(incoming.get("unlocked_corals", []))

	var incoming_history: Variant = incoming.get("classification_history", [])
	var history: Array = []
	if typeof(incoming_history) == TYPE_ARRAY:
		for entry in incoming_history:
			if typeof(entry) == TYPE_DICTIONARY:
				history.append(entry)
	state["classification_history"] = history

	var incoming_queue: Variant = incoming.get("pending_offline_classifications", [])
	var queue: Array = []
	if typeof(incoming_queue) == TYPE_ARRAY:
		for entry in incoming_queue:
			if typeof(entry) == TYPE_DICTIONARY:
				queue.append(entry)
	state["pending_offline_classifications"] = queue

	var incoming_tank: Variant = incoming.get("tank", null)
	if typeof(incoming_tank) == TYPE_DICTIONARY:
		state["tank"] = incoming_tank

	state["tutorial_complete"] = bool(incoming.get("tutorial_complete", false))
	var incoming_tooltips: Variant = incoming.get("stressor_tooltip_shown", {})
	if typeof(incoming_tooltips) == TYPE_DICTIONARY:
		state["stressor_tooltip_shown"] = incoming_tooltips
	else:
		state["stressor_tooltip_shown"] = {}

	_touch_state()


func _touch_state() -> void:
	state["updated_at"] = Time.get_datetime_string_from_system(true)
	_persist_local_state()
	_persist_pending_classifications()


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
		"global_coins": int(state.get("global_coins", 0)),
		"carryover_triggers": get_carryover_triggers(),
		"last_coins_earned": int(state.get("last_coins_earned", 0)),
		"pending_rewards": state.get("pending_rewards", []).duplicate(true),
		"pending_reward_total": get_pending_reward_total(),
		"classification_bonus_total": int(state.get("classification_bonus_total", 0)),
		"unlocked_corals": state.get("unlocked_corals", []).duplicate(true),
		"classification_history": state.get("classification_history", []).duplicate(true),
		"pending_offline_classifications": state.get("pending_offline_classifications", []).duplicate(true),
		"tutorial_complete": bool(state.get("tutorial_complete", false)),
		"stressor_tooltip_shown": state.get("stressor_tooltip_shown", {}).duplicate(true),
		"tank": _get_tank().duplicate(true),
		"tank_pending_coins": get_tank_pending_coins(),
		"current_level_available_nutrients": _get_level_available_nutrients(current_level),
		"current_level_definition": _get_level_definition(current_level),
		"updated_at": str(state.get("updated_at", "")),
		"level_count": LEVEL_COUNT,
		"max_unlocked_level": _max_unlocked_level(),
	}


func normalize_label(raw: String) -> String:
	return raw.to_lower().strip_edges().replace(".", "").replace("-", " ").replace("_", " ")


func _normalize_label(raw: String) -> String:
	return normalize_label(raw)


func to_string_array(value: Variant) -> Array:
	var output: Array = []
	if typeof(value) == TYPE_ARRAY:
		for v in value:
			output.append(str(v))
	return output


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
