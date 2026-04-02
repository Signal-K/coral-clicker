extends Node

var main_scene: Node = null
var app_controller: Node = null
var screenshot_dir := "user://visual_e2e"
const STEP_PAUSE := 1.2
var _capture_manifest: Array[Dictionary] = []


func _ready() -> void:
	if get_parent() != get_tree().root:
		call_deferred("_reparent_to_root")
		return
	call_deferred("_run")


func _reparent_to_root() -> void:
	get_parent().remove_child(self)
	get_tree().root.add_child(self)
	call_deferred("_run")


func _run() -> void:
	_resolve_screenshot_dir()
	_prepare_controller()

	await _scenario_tutorial_route()
	await _scenario_stressor_route()
	await _scenario_annotation_route()
	await _scenario_tank_route()

	_flush_capture_manifest()
	print("[VISUAL E2E] Screenshots saved to: ", screenshot_dir)
	get_tree().quit(0)


func _scenario_tutorial_route() -> void:
	print("[VISUAL E2E] Tutorial route")
	_reset_progress([], 1, false)
	print("[VISUAL E2E] Loading fresh home")
	await _load_home()
	print("[VISUAL E2E] Home ready")
	await _capture("01_home_fresh")
	await _settle(STEP_PAUSE)

	print("[VISUAL E2E] Entering tutorial level")
	var level_system = await _enter_level(1)
	print("[VISUAL E2E] Level entered")
	await _capture("02_level1_identify")
	await _settle(STEP_PAUSE)
	await _confirm_identify(level_system, true)
	print("[VISUAL E2E] Identify confirmed")
	await _capture("03_level1_goal")
	await _settle(STEP_PAUSE)

	level_system._on_tutorial_advanced()
	print("[VISUAL E2E] Tutorial advanced to feed step")
	await _settle()
	await _capture("04_level1_feed")
	await _settle(STEP_PAUSE)

	if level_system._fish_species_order.is_empty():
		_fail("No fish available for tutorial visual pass")
		return
	var helper_species: String = level_system._tutorial_focus_species()
	if helper_species.is_empty():
		helper_species = level_system._fish_species_order[0]
	level_system._adjust_fish(helper_species, 1)
	print("[VISUAL E2E] Helper fish adjusted: ", helper_species)
	await _settle()
	await _capture("05_level1_turn_ready")
	await _settle(STEP_PAUSE)

	level_system._on_tutorial_advanced()
	print("[VISUAL E2E] Advancing tutorial turn")
	await level_system._advance_turn()
	await _settle(1.2)
	await _capture("06_level1_results")
	await _settle(STEP_PAUSE)

	level_system._on_turn_results_continued()
	print("[VISUAL E2E] Results continued")
	await _settle()
	level_system._coral_population = level_system._target_population
	level_system._update_text()
	await level_system._advance_turn()
	print("[VISUAL E2E] Forced tutorial win step")
	await _settle(1.0)
	await _capture("07_level1_win")
	await _settle(STEP_PAUSE)

	level_system._on_tutorial_advanced()
	await _settle()
	level_system._on_level_end_home()
	print("[VISUAL E2E] Returning home after tutorial")
	await _wait_for_scene("Home", 3.0)
	await _capture("08_home_after_tutorial")
	await _settle(STEP_PAUSE)


func _scenario_stressor_route() -> void:
	print("[VISUAL E2E] Stressor route")
	_reset_progress([1, 2, 3], 4, true)
	await _load_home()
	await _capture("09_home_midroute")
	await _settle(STEP_PAUSE)

	var level_system = await _enter_level(4)
	await _confirm_identify(level_system, true)
	await _capture("10_level4_board")
	await _settle(STEP_PAUSE)

	await level_system._advance_turn()
	await _settle(0.8)
	await _capture("11_level4_stressor")
	await _settle(STEP_PAUSE)

	level_system._on_stressor_tooltip_dismissed()
	await _settle(1.0)
	if level_system._showing_turn_results:
		await _capture("12_level4_results")
		await _settle(STEP_PAUSE)
		level_system._on_turn_results_continued()
		await _settle()

	level_system._go_home()
	await _wait_for_scene("Home", 3.0)


func _scenario_annotation_route() -> void:
	print("[VISUAL E2E] Annotation route")
	_reset_progress([1, 2, 3, 4], 5, true)
	await _load_home()
	await _capture("13_home_frontier")
	await _settle(STEP_PAUSE)

	var level_system = await _enter_level(5)
	await _confirm_identify(level_system, true)
	await _capture("14_level5_board")
	await _settle(STEP_PAUSE)

	level_system._coral_population = level_system._target_population
	level_system._update_text()
	await level_system._advance_turn()
	await _settle(1.0)

	if level_system._classification_dialog and level_system._classification_dialog.visible:
		await _capture("15_level5_annotator")
		await _settle(STEP_PAUSE)
		_select_classification_answer(level_system, true)
		level_system._on_classification_confirmed()
		await _settle()

	await _capture("16_level5_win")
	await _settle(STEP_PAUSE)
	level_system._on_level_end_home()
	await _wait_for_scene("Home", 3.0)


func _scenario_tank_route() -> void:
	print("[VISUAL E2E] Tank route")
	var tank_state: Dictionary = app_controller.state.get("tank", {}).duplicate(true)
	tank_state["last_collect_timestamp"] = int(Time.get_unix_time_from_system()) - 7200
	tank_state["accumulated_coins"] = 0
	tank_state["fish_populations"] = {
		"Blue Chromis": 5,
		"Sergeant Major": 3,
	}
	tank_state["coral_population"] = 7
	app_controller.state["tank"] = tank_state
	app_controller.state["global_coins"] = 80
	app_controller._touch_state()
	app_controller.emit_level_state()

	await _load_home()
	var tank_button := get_tree().current_scene.find_child("TankButton", true, false) as Button
	if tank_button == null:
		_fail("Could not find TankButton on Home")
		return
	await _simulate_click(tank_button)
	if get_tree().current_scene == main_scene:
		print("[VISUAL E2E] Tank button click did not change scene, emitting pressed signal")
		tank_button.emit_signal("pressed")
		await _settle()
	await _wait_for_scene("TheTank", 4.0)
	await _capture("17_tank_overview")
	await _settle(STEP_PAUSE)

	var tank_scene = get_tree().current_scene
	tank_scene._on_tank_fish_adjust("Blue Chromis", 1)
	tank_scene._on_collect_pressed()
	await _settle()
	await _capture("18_tank_after_collect")
	await _settle(STEP_PAUSE)

	tank_scene._go_to_levels()
	await _wait_for_scene("Home", 3.0)
	await _capture("19_home_return")


func _resolve_screenshot_dir() -> void:
	var env_dir := OS.get_environment("SCREENSHOT_DIR")
	if not env_dir.is_empty():
		screenshot_dir = env_dir
	DirAccess.make_dir_recursive_absolute(screenshot_dir)


func _prepare_controller() -> void:
	app_controller = get_tree().root.get_node_or_null("AppController")
	if app_controller == null:
		var app_controller_script = load("res://app_controller.gd")
		app_controller = app_controller_script.new()
		app_controller.name = "AppController"
		get_tree().root.add_child(app_controller)


func _reset_progress(completed_levels: Array, current_level: int, tutorial_complete: bool) -> void:
	app_controller.state["completed_levels"] = completed_levels.duplicate(true)
	app_controller.state["current_level"] = current_level
	app_controller.state["tutorial_complete"] = tutorial_complete
	app_controller.state["stressor_tooltip_shown"] = {}
	app_controller.state["pending_rewards"] = []
	app_controller._touch_state()
	app_controller.emit_level_state()


func _load_home() -> void:
	var existing_scene := get_tree().current_scene
	if existing_scene != null and existing_scene != self:
		print("[VISUAL E2E] Queue freeing scene ", existing_scene.name)
		existing_scene.queue_free()
		await get_tree().process_frame
	var home_scene_pack = load("res://home.tscn")
	if home_scene_pack == null:
		_fail("Failed to load home.tscn")
		return
	var home_scene = home_scene_pack.instantiate()
	get_tree().root.add_child(home_scene)
	get_tree().current_scene = home_scene
	main_scene = home_scene
	await _settle()


func _enter_level(level_number: int) -> Node:
	var home_scene := get_tree().current_scene
	print("[VISUAL E2E] Searching level button ", level_number)
	var levels_root := home_scene.find_child("LevelsGrid", true, false)
	if levels_root == null:
		_fail("Could not find LevelsGrid")
		return null
	var button := levels_root.get_node_or_null("LevelButton%d" % level_number) as Button
	if button == null:
		_fail("Could not find LevelButton%d" % level_number)
		return null
	await _simulate_click(button)
	if get_tree().current_scene == home_scene:
		print("[VISUAL E2E] Button click did not change scene, emitting pressed signal")
		button.emit_signal("pressed")
		await _settle()
	await _wait_for_game_scene()
	return main_scene


func _wait_for_game_scene() -> void:
	var timeout := 10.0
	while timeout > 0.0:
		for child in get_tree().root.get_children():
			if child.name == "Main" or child.name == "GameScreen":
					main_scene = child
					await _settle()
					return
		await get_tree().create_timer(0.5).timeout
		timeout -= 0.5
	print("[VISUAL E2E] Falling back to direct scene change for game scene")
	get_tree().change_scene_to_file("res://main.tscn")
	await _wait_for_scene("GameScreen", 4.0)
	main_scene = get_tree().current_scene


func _wait_for_scene(scene_name: String, timeout: float) -> void:
	var remaining := timeout
	while remaining > 0.0:
		if get_tree().current_scene != null and get_tree().current_scene.name == scene_name:
			await _settle()
			return
		await get_tree().create_timer(0.25).timeout
		remaining -= 0.25
	_fail("Timed out waiting for scene %s" % scene_name)
	return


func _confirm_identify(level_system: Node, prefer_correct: bool) -> void:
	await _settle()
	var scene = level_system._identify_phase_scene
	if scene == null or scene.chips.is_empty():
		_fail("Identify choices were not available")
		return

	var chosen = scene.chips[0]
	if prefer_correct:
		var canonical := str(level_system._identify_subject.get("canonical_name", ""))
		for chip in scene.chips:
			if str(chip.species_name) == canonical:
				chosen = chip
				break

	chosen.button_pressed = true
	scene.submit_identification()
	await _settle()


func _select_classification_answer(level_system: Node, prefer_correct: bool) -> void:
	if level_system == null or level_system._classification_guess_option == null:
		return
	if level_system._classification_guess_option.item_count <= 0:
		return
	var selected := 0
	if prefer_correct:
		var canonical := str(level_system._pending_classification.get("canonical_name", ""))
		for i in range(level_system._classification_guess_option.item_count):
			if level_system._classification_guess_option.get_item_text(i) == canonical:
				selected = i
				break
	level_system._classification_guess_option.select(selected)


func _capture(name: String) -> void:
	var scene_name: String = get_tree().current_scene.name if get_tree().current_scene != null else "none"
	if _is_headless_runtime():
		_capture_manifest.append({
			"name": name,
			"scene": scene_name,
			"timestamp": Time.get_datetime_string_from_system(true),
		})
		print("[VISUAL E2E] Recorded headless audit step ", name, " in scene ", scene_name)
		return
	else:
		await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := "%s/%s.png" % [screenshot_dir, name]
	var err := image.save_png(path)
	if err != OK:
		_fail("Failed to save screenshot %s" % path)
		return
	print("[VISUAL E2E] Captured ", path)


func _is_headless_runtime() -> bool:
	return DisplayServer.get_name() == "headless" or OS.has_feature("headless")


func _flush_capture_manifest() -> void:
	var path := "%s/capture_manifest.json" % screenshot_dir
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_fail("Failed to write capture manifest %s" % path)
		return
	file.store_string(JSON.stringify({"steps": _capture_manifest}, "\t"))
	print("[VISUAL E2E] Wrote manifest ", path)


func _simulate_click(node: Control) -> void:
	if not node.is_inside_tree():
		return
	var click_pos := node.get_screen_transform().origin + node.get_size() / 2
	var press_event := InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_LEFT
	press_event.pressed = true
	press_event.position = click_pos
	Input.parse_input_event(press_event)
	await get_tree().create_timer(0.1).timeout
	var release_event := InputEventMouseButton.new()
	release_event.button_index = MOUSE_BUTTON_LEFT
	release_event.pressed = false
	release_event.position = click_pos
	Input.parse_input_event(release_event)
	await _settle()


func _settle(duration: float = 0.35) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout


func _fail(message: String) -> void:
	printerr("[VISUAL E2E ERROR] ", message)
	get_tree().quit(1)
