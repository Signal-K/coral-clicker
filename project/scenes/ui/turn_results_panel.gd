extends CanvasLayer

signal continued

@onready var title_label: Label = $PanelContainer/Margin/VBox/Title
@onready var rows_vbox: VBoxContainer = $PanelContainer/Margin/VBox/RowsScroll/RowsVBox
@onready var nutrients_label: Label = $PanelContainer/Margin/VBox/StatsVBox/NutrientsLabel
@onready var health_bar: ProgressBar = $PanelContainer/Margin/VBox/StatsVBox/HealthRow/HealthBar
@onready var health_value_label: Label = $PanelContainer/Margin/VBox/StatsVBox/HealthRow/HealthValue
@onready var continue_button: Button = $PanelContainer/Margin/VBox/ContinueButton
@onready var panel_container: PanelContainer = $PanelContainer
@onready var dim_bg: ColorRect = $DimBG

var RowScene = preload("res://scenes/ui/TurnResultRow.tscn")

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	hide_panel()

func show_results(turn_num: int, total_turns: int, current_populations: Dictionary, target_populations: Dictionary, turns_remaining: int) -> void:
	title_label.text = "Turn %d of %d — Results" % [turn_num, total_turns]
	if turns_remaining <= 0:
		nutrients_label.text = "Last turn"
	else:
		nutrients_label.text = "%d turns remaining" % turns_remaining
	var coral_target := 0
	var coral_current := 0
	for species in target_populations.keys():
		if int(target_populations.get(species, 0)) > coral_target:
			coral_target = int(target_populations.get(species, 0))
			coral_current = int(current_populations.get(species, 0))
	var reef_ratio := 0.0 if coral_target <= 0 else float(coral_current) / float(coral_target)
	health_bar.value = reef_ratio * 100.0
	health_value_label.text = "%d%%" % int(reef_ratio * 100.0)
	
	# Clear existing rows
	for child in rows_vbox.get_children():
		child.queue_free()
	
	visible = true
	dim_bg.modulate.a = 0
	panel_container.modulate.a = 0
	panel_container.position.y += 50
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(dim_bg, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel_container, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel_container, "position:y", panel_container.position.y - 50, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var species_names: Array[String] = []
	for species in target_populations.keys():
		var target_name := str(species)
		if not species_names.has(target_name):
			species_names.append(target_name)
	for species in current_populations.keys():
		var current_name := str(species)
		if not species_names.has(current_name):
			species_names.append(current_name)
	species_names.sort()

	# Add rows with stagger
	var idx = 0
	for species in species_names:
		var row = RowScene.instantiate()
		rows_vbox.add_child(row)
		
		var species_label = row.get_node("SpeciesLabel")
		var delta_label = row.get_node("DeltaLabel")
		var arrow_label = row.get_node("Arrow")
		var icon = row.get_node("Icon")
		var current_value := int(current_populations.get(species, 0))
		var target_value := int(target_populations.get(species, 0))
		
		species_label.text = species
		delta_label.text = "%d / %d" % [current_value, target_value]
		
		if current_value == target_value or (target_value == 0 and current_value <= 0):
			arrow_label.text = "On target"
			delta_label.add_theme_color_override("font_color", Color.GREEN)
			arrow_label.add_theme_color_override("font_color", Color.GREEN)
		elif current_value > target_value:
			arrow_label.text = "Over"
			delta_label.add_theme_color_override("font_color", Color.GREEN)
			arrow_label.add_theme_color_override("font_color", Color.GREEN)
		else:
			arrow_label.text = "Below"
			delta_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92))
			arrow_label.add_theme_color_override("font_color", Color(0.82, 0.82, 0.82))
			
		# Try to load icon
		var slug = species.to_lower().replace(" ", "_")
		var icon_path = "res://assets/sprites/%s_frame_00.png" % slug
		if FileAccess.file_exists(icon_path):
			icon.texture = load(icon_path)
		
		row.modulate.a = 0
		row.position.x -= 20
		var row_tween = create_tween()
		row_tween.set_parallel(true)
		row_tween.tween_interval(0.3 + idx * 0.15)
		row_tween.chain().tween_property(row, "modulate:a", 1.0, 0.2)
		row_tween.tween_property(row, "position:x", row.position.x + 20, 0.2)
		idx += 1

func hide_panel() -> void:
	visible = false

func _on_continue_pressed() -> void:
	continued.emit()
	hide_panel()
