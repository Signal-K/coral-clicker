extends Control

signal egg_purchased(species_id: String)
signal closed

func setup(available_species: Array, coins: int) -> void:
	$Panel/VBox/CoinsLabel.text = "🪙 %d" % coins
	_build_items(available_species, coins)

func _build_items(species: Array, coins: int) -> void:
	var grid := $Panel/VBox/ItemsGrid
	for child in grid.get_children():
		child.queue_free()

	for sid in species:
		var sid_str: String = str(sid)
		var name_str: String = sid_str.replace("_", " ").capitalize()
		var item := VBoxContainer.new()
		item.custom_minimum_size = Vector2(100, 100)

		var icon_btn := Button.new()
		icon_btn.text = "🥚"
		icon_btn.custom_minimum_size = Vector2(64, 64)
		icon_btn.add_theme_font_size_override("font_size", 28)
		icon_btn.disabled = coins < 5
		icon_btn.modulate.a = 0.5 if coins < 5 else 1.0
		icon_btn.pressed.connect(func(): egg_purchased.emit(sid_str))

		var name_lbl := Label.new()
		name_lbl.text = name_str
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 10)
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD

		var cost_lbl := Label.new()
		cost_lbl.text = "5 🪙"
		cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_lbl.add_theme_font_size_override("font_size", 10)
		cost_lbl.add_theme_color_override("font_color", Color(1.0, 0.906, 0.573, 1.0))

		item.add_child(icon_btn)
		item.add_child(name_lbl)
		item.add_child(cost_lbl)
		grid.add_child(item)

func _ready() -> void:
	$Panel/VBox/Header/CloseButton.pressed.connect(func(): closed.emit())
