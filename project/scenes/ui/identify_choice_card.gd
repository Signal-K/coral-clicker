extends Button

@onready var preview: TextureRect = $Margin/VBox/PreviewFrame/Preview
@onready var species_label: Label = $Margin/VBox/SpeciesLabel
@onready var state_label: Label = $Margin/VBox/StateLabel

var species_name := ""


func _ready() -> void:
	toggle_mode = true
	toggled.connect(_on_toggled)
	_update_style()


func setup(p_species: String, p_texture: Texture2D) -> void:
	species_name = p_species
	species_label.text = species_name
	preview.texture = p_texture
	preview.visible = p_texture != null


func _on_toggled(is_pressed: bool) -> void:
	state_label.text = "Selected" if is_pressed else "Tap to select"
	_update_style()


func _update_style() -> void:
	add_theme_stylebox_override("normal", _make_style(
		Color(0.08, 0.12, 0.18, 0.96),
		Color(0.18, 0.28, 0.38, 1.0)
	))
	add_theme_stylebox_override("hover", _make_style(
		Color(0.11, 0.16, 0.23, 0.98),
		Color(0.36, 0.56, 0.72, 1.0)
	))
	add_theme_stylebox_override("pressed", _selected_style())
	add_theme_stylebox_override("focus", _selected_style())

	if button_pressed:
		add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
		species_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
		state_label.add_theme_color_override("font_color", Color(1.0, 0.89, 0.56, 1.0))
	else:
		add_theme_color_override("font_color", Color(0.88, 0.93, 0.98, 1.0))
		species_label.add_theme_color_override("font_color", Color(0.88, 0.93, 0.98, 1.0))
		state_label.add_theme_color_override("font_color", Color(0.63, 0.74, 0.83, 1.0))


func _selected_style() -> StyleBoxFlat:
	return _make_style(
		Color(0.15, 0.21, 0.3, 1.0),
		Color(0.99, 0.81, 0.35, 1.0),
		4,
		Color(0.99, 0.81, 0.35, 0.18),
		16
	)


func _make_style(bg: Color, border: Color, border_width: int = 2, shadow: Color = Color(0, 0, 0, 0.2), shadow_size: int = 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	style.content_margin_left = 14
	style.content_margin_top = 14
	style.content_margin_right = 14
	style.content_margin_bottom = 14
	style.shadow_color = shadow
	style.shadow_size = shadow_size
	return style
