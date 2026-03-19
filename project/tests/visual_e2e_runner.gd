extends Node

var main_scene: Control = null
var app_controller: Node = null
var screenshot_dir := "user://visual_e2e"


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
	await _load_home()
	await _capture("01_home")

	await _enter_level_one()
	await _wait_for_main_scene()
	await _capture("02_identify_tutorial")

	var level_system := main_scene
	level_system._identify_choice_checks[0].button_pressed = true
	level_system._on_identify_confirmed()
	await _settle()
	await _capture("03_goal_intro")

	level_system._on_tutorial_advanced()
	await _settle()
	await _capture("04_feed_step")

	if level_system._fish_species_order.is_empty():
		_fail("No fish available for tutorial visual pass")
		return
	level_system._adjust_fish(level_system._fish_species_order[0], 1)
	await _settle()
	await _capture("05_end_turn_step")

	level_system._on_tutorial_advanced()
	await level_system._advance_turn()
	await _settle(1.2)
	await _capture("06_results_panel")

	level_system._on_turn_results_continued()
	await _settle()

	level_system._coral_population = level_system._target_population
	level_system._update_text()
	await level_system._advance_turn()
	await _settle(1.0)
	await _capture("07_win_tutorial")

	level_system._on_tutorial_advanced()
	await _settle()
	level_system._go_home()
	await _settle(1.0)
	await _capture("08_home_return")

	print("[VISUAL E2E] Screenshots saved to: ", screenshot_dir)
	get_tree().quit(0)


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
	app_controller.state["current_level"] = 1
	app_controller.state["completed_levels"] = []
	app_controller.state["tutorial_complete"] = false
	app_controller._touch_state()
	app_controller.emit_level_state()


func _load_home() -> void:
	var home_scene_pack = load("res://home.tscn")
	if home_scene_pack == null:
		_fail("Failed to load home.tscn")
		return
	var home_scene = home_scene_pack.instantiate()
	get_tree().root.add_child(home_scene)
	get_tree().current_scene = home_scene
	main_scene = home_scene
	await _settle()


func _enter_level_one() -> void:
	var levels_grid := main_scene.find_child("LevelsGrid", true, false)
	if levels_grid == null:
		_fail("Could not find LevelsGrid")
		return
	var level_button := levels_grid.get_node_or_null("LevelButton1")
	if level_button == null:
		_fail("Could not find LevelButton1")
		return
	await _simulate_click(level_button)


func _wait_for_main_scene() -> void:
	var timeout := 10.0
	while timeout > 0.0:
		for child in get_tree().root.get_children():
			if child.name == "Main" or child.name == "GameScreen":
				main_scene = child
				await _settle()
				return
		await get_tree().create_timer(0.5).timeout
		timeout -= 0.5
	get_tree().change_scene_to_file("res://main.tscn")
	await _settle(1.0)
	main_scene = get_tree().current_scene


func _capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.flip_y()
	var path := "%s/%s.png" % [screenshot_dir, name]
	var err := image.save_png(path)
	if err != OK:
		_fail("Failed to save screenshot %s" % path)


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
