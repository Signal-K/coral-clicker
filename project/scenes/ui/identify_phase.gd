extends CanvasLayer

signal submitted(species: Array[String])
signal skipped
signal identify_ready(is_ready: bool)

@onready var intro_label: RichTextLabel = $Control/Margin/VBox/IntroLabel
@onready var identify_image: TextureRect = $Control/Margin/VBox/ImageContainer/IdentifyImage
@onready var source_label: Label = $Control/Margin/VBox/SourceLabel
@onready var grid: GridContainer = $Control/Margin/VBox/Scroll/Grid
@onready var submit_button: Button = $Control/Margin/VBox/Actions/SubmitButton
@onready var skip_button: Button = $Control/Margin/VBox/Actions/SkipButton

var species_chip_scene: PackedScene = preload("res://scenes/ui/SpeciesChip.tscn")
var marker_scene: PackedScene = preload("res://scenes/ui/IdentifyMarker.tscn")
var chips: Array[Button] = []
var _markers: Dictionary = {} # species_name -> Control
var _active_species_for_marking: String = ""

func _ready() -> void:
	submit_button.pressed.connect(submit_identification)
	skip_button.pressed.connect(func(): skipped.emit())
	identify_image.gui_input.connect(_on_image_gui_input)
	_update_submit_state()

func setup(intro_text: String, texture: Texture, source_text: String, choices: Array[String], sprite_frames_map: Dictionary) -> void:
	intro_label.text = intro_text
	identify_image.texture = texture
	source_label.text = source_text
	
	for child in grid.get_children():
		child.queue_free()
	chips.clear()
	
	for marker in _markers.values():
		marker.queue_free()
	_markers.clear()
	_active_species_for_marking = ""
	
	for species in choices:
		var chip = species_chip_scene.instantiate()
		grid.add_child(chip)
		var frames = sprite_frames_map.get(species)
		chip.setup(species, frames)
		chip.toggled.connect(_on_chip_toggled.bind(species))
		chips.append(chip)
	
	_update_submit_state()

func _on_chip_toggled(pressed: bool, species: String) -> void:
	if pressed:
		_active_species_for_marking = species
		# If already has a marker, just show it
		if _markers.has(species):
			_markers[species].visible = true
	else:
		if _active_species_for_marking == species:
			_active_species_for_marking = ""
		if _markers.has(species):
			_markers[species].queue_free()
			_markers.erase(species)
	
	_update_submit_state()

func _on_image_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _active_species_for_marking.is_empty():
			return
		
		var pos = event.position
		_place_marker(_active_species_for_marking, pos)

func _place_marker(species: String, pos: Vector2) -> void:
	if _markers.has(species):
		_markers[species].position = pos
	else:
		var marker = marker_scene.instantiate()
		identify_image.add_child(marker)
		marker.position = pos
		marker.get_node("Label").text = species
		_markers[species] = marker
	
	_update_submit_state()

func _update_submit_state() -> void:
	var selected = _selected_species()
	var has_markers = _markers.size() > 0
	var is_ready := not selected.is_empty() and has_markers
	
	submit_button.disabled = not is_ready
	identify_ready.emit(is_ready)
	
	if selected.is_empty():
		submit_button.text = "Select species below"
	elif not has_markers:
		submit_button.text = "Click image to place indicator"
	else:
		submit_button.text = "Confirm Identification (+5 coins)"

func _selected_species() -> Array[String]:
	var result: Array[String] = []
	for chip in chips:
		if chip.button_pressed:
			result.append(chip.species_name)
	return result

func submit_identification() -> void:
	submitted.emit(_selected_species())
