extends Control
# The Tank — persistent sandbox hub. Idle coin generation, population management,
# and the gateway to puzzle levels.

const HOME_SCENE := "res://home.tscn"
const COIN_COLLECT_MIN := 1

var controller: Node = null

# Dynamic UI refs (built programmatically in _ready)
var _coins_label: Label = null
var _pending_label: Label = null
var _collect_btn: Button = null
var _tank_info_label: RichTextLabel = null
var _status_label: Label = null
var _fish_rows_container: VBoxContainer = null

# Timer for refreshing pending coins display
var _refresh_timer: float = 0.0
const REFRESH_INTERVAL := 10.0


func _ready() -> void:
	controller = get_node_or_null("/root/AppController")
	_build_ui()
	if controller:
		if controller.has_signal("level_progress_changed"):
			controller.level_progress_changed.connect(_on_state_changed)
		if controller.has_method("start_tank_timer"):
			controller.call("start_tank_timer")
		if controller.has_method("emit_level_state"):
			controller.call("emit_level_state")
	_refresh_display()


func _process(delta: float) -> void:
	_refresh_timer += delta
	if _refresh_timer >= REFRESH_INTERVAL:
		_refresh_timer = 0.0
		_refresh_display()


func _build_ui() -> void:
	# Full-screen deep ocean background
	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.03, 0.08, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var outer_margin := MarginContainer.new()
	outer_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer_margin.add_theme_constant_override("margin_left", 32)
	outer_margin.add_theme_constant_override("margin_right", 32)
	outer_margin.add_theme_constant_override("margin_top", 24)
	outer_margin.add_theme_constant_override("margin_bottom", 24)
	add_child(outer_margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	outer_margin.add_child(vbox)

	# ── Title row ──
	var title_row := HBoxContainer.new()
	vbox.add_child(title_row)

	var title := Label.new()
	title.text = "The Tank"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.94, 0.91, 0.71))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)

	var levels_btn := Button.new()
	levels_btn.text = "Select Levels"
	levels_btn.pressed.connect(_go_to_levels)
	title_row.add_child(levels_btn)

	# ── Coins banner ──
	var coins_panel := PanelContainer.new()
	vbox.add_child(coins_panel)

	var coins_margin := MarginContainer.new()
	coins_margin.add_theme_constant_override("margin_left", 16)
	coins_margin.add_theme_constant_override("margin_right", 16)
	coins_margin.add_theme_constant_override("margin_top", 10)
	coins_margin.add_theme_constant_override("margin_bottom", 10)
	coins_panel.add_child(coins_margin)

	var coins_row := HBoxContainer.new()
	coins_row.add_theme_constant_override("separation", 20)
	coins_margin.add_child(coins_row)

	_coins_label = Label.new()
	_coins_label.text = "Coins: 0"
	_coins_label.add_theme_font_size_override("font_size", 20)
	_coins_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coins_row.add_child(_coins_label)

	_pending_label = Label.new()
	_pending_label.text = "Pending: 0"
	_pending_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	coins_row.add_child(_pending_label)

	_collect_btn = Button.new()
	_collect_btn.text = "Collect"
	_collect_btn.pressed.connect(_on_collect_pressed)
	coins_row.add_child(_collect_btn)

	# ── Tank info / populations ──
	var info_panel := PanelContainer.new()
	info_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(info_panel)

	var info_margin := MarginContainer.new()
	info_margin.add_theme_constant_override("margin_left", 16)
	info_margin.add_theme_constant_override("margin_right", 16)
	info_margin.add_theme_constant_override("margin_top", 12)
	info_margin.add_theme_constant_override("margin_bottom", 12)
	info_panel.add_child(info_margin)

	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 8)
	info_margin.add_child(info_vbox)

	var info_title := Label.new()
	info_title.text = "Your Reef"
	info_title.add_theme_font_size_override("font_size", 18)
	info_vbox.add_child(info_title)

	_tank_info_label = RichTextLabel.new()
	_tank_info_label.fit_content = true
	_tank_info_label.bbcode_enabled = true
	_tank_info_label.scroll_active = false
	info_vbox.add_child(_tank_info_label)

	var sep := HSeparator.new()
	info_vbox.add_child(sep)

	var fish_title := Label.new()
	fish_title.text = "Fish Populations (tap +/- to adjust)"
	info_vbox.add_child(fish_title)

	_fish_rows_container = VBoxContainer.new()
	_fish_rows_container.add_theme_constant_override("separation", 4)
	info_vbox.add_child(_fish_rows_container)

	# ── Status ──
	_status_label = Label.new()
	_status_label.text = "Your tank earns coins while you play levels."
	_status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_status_label)


func _refresh_display() -> void:
	if controller == null:
		return

	var coins := 0
	if controller.has_method("get_coins"):
		coins = controller.call("get_coins")

	var pending := 0
	if controller.has_method("get_tank_pending_coins"):
		pending = controller.call("get_tank_pending_coins")

	if _coins_label:
		_coins_label.text = "Coins: %d" % coins
	if _pending_label:
		_pending_label.text = "Pending: +%d" % pending
	if _collect_btn:
		_collect_btn.disabled = pending < COIN_COLLECT_MIN

	var tank_json := "{}"
	if controller.has_method("get_tank_state_json"):
		tank_json = controller.call("get_tank_state_json")
	var tank := JSON.parse_string(tank_json)
	if typeof(tank) != TYPE_DICTIONARY:
		tank = {}

	# Tank info
	if _tank_info_label:
		var target_coral := str(tank.get("target_coral", "Unknown"))
		var coral_pop := int(tank.get("coral_population", 0))
		var fish_pops: Dictionary = tank.get("fish_populations", {})
		var fish_total := 0
		for sp in fish_pops.keys():
			fish_total += int(fish_pops[sp])

		var rate_per_hour := float(coral_pop) * 1.0 + float(fish_total) * 0.3
		_tank_info_label.text = "Coral: [b]%s[/b] × %d\nFish: %d total\nRate: [b]%.1f coins/hour[/b]" % [target_coral, coral_pop, fish_total, rate_per_hour]

	# Fish population rows
	_refresh_fish_rows(tank.get("fish_populations", {}))


func _refresh_fish_rows(fish_pops: Variant) -> void:
	if _fish_rows_container == null:
		return
	for child in _fish_rows_container.get_children():
		child.queue_free()

	if typeof(fish_pops) != TYPE_DICTIONARY:
		return

	var species_list: Array = []
	for sp in fish_pops.keys():
		species_list.append(str(sp))
	species_list.sort()

	for species in species_list:
		var pop := int(fish_pops[species])
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_fish_rows_container.add_child(row)

		var lbl := Label.new()
		lbl.text = "%s: %d" % [species, pop]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		var plus_btn := Button.new()
		plus_btn.text = "+"
		plus_btn.custom_minimum_size = Vector2(32, 0)
		plus_btn.pressed.connect(Callable(self, "_on_tank_fish_adjust").bind(species, 1))
		row.add_child(plus_btn)

		var minus_btn := Button.new()
		minus_btn.text = "-"
		minus_btn.custom_minimum_size = Vector2(32, 0)
		minus_btn.disabled = pop <= 0
		minus_btn.pressed.connect(Callable(self, "_on_tank_fish_adjust").bind(species, -1))
		row.add_child(minus_btn)


func _on_collect_pressed() -> void:
	if controller == null or not controller.has_method("collect_tank_rewards"):
		return
	var collected: int = controller.call("collect_tank_rewards")
	if _status_label:
		_status_label.text = "Collected %d coins! Keep growing your reef." % collected
	_refresh_display()


func _on_tank_fish_adjust(species: String, delta: int) -> void:
	if controller == null or not controller.has_method("update_tank_population"):
		return
	controller.call("update_tank_population", species, delta)
	_refresh_display()


func _on_state_changed(_payload_json: String) -> void:
	_refresh_display()


func _go_to_levels() -> void:
	get_tree().change_scene_to_file(HOME_SCENE)
