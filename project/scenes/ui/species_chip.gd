extends Button

@onready var anim_sprite: AnimatedSprite2D = $HBox/SpriteContainer/AnimatedSprite2D
@onready var species_label: Label = $HBox/SpeciesLabel

var species_name: String = ""
var is_checked: bool = false

func setup(p_species: String, frames: SpriteFrames) -> void:
	species_name = p_species
	species_label.text = species_name
	if frames:
		anim_sprite.sprite_frames = frames
		anim_sprite.play("default")
	else:
		$HBox/SpriteContainer.visible = false

func _ready() -> void:
	toggle_mode = true
	toggled.connect(_on_toggled)
	_update_style()

func _on_toggled(button_pressed: bool) -> void:
	is_checked = button_pressed
	_update_style()

func _update_style() -> void:
	if is_checked:
		add_theme_color_override("font_color", Color(1, 1, 1, 1))
		add_theme_stylebox_override("normal", _make_style(Color(0.18, 0.38, 0.65, 0.9), Color(0.4, 0.7, 1.0, 1.0)))
		add_theme_stylebox_override("hover", _make_style(Color(0.22, 0.45, 0.75, 1.0), Color(0.5, 0.8, 1.0, 1.0)))
		add_theme_stylebox_override("pressed", _make_style(Color(0.15, 0.35, 0.6, 1.0), Color(0.4, 0.7, 1.0, 1.0)))
	else:
		add_theme_color_override("font_color", Color(0.8, 0.85, 0.9, 0.8))
		add_theme_stylebox_override("normal", _make_style(Color(0.12, 0.15, 0.22, 0.6), Color(0.2, 0.25, 0.35, 0.5)))
		add_theme_stylebox_override("hover", _make_style(Color(0.15, 0.2, 0.3, 0.8), Color(0.3, 0.4, 0.5, 0.7)))
		add_theme_stylebox_override("pressed", _make_style(Color(0.1, 0.12, 0.18, 0.9), Color(0.2, 0.25, 0.35, 0.5)))

func _make_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 8
	style.content_margin_top = 4
	style.content_margin_right = 8
	style.content_margin_bottom = 4
	return style
