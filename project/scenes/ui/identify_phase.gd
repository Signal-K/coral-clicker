extends CanvasLayer

signal submitted(species: Array[String])
signal skipped
signal identify_ready(is_ready: bool)

@onready var title_label: Label = $Control/Margin/Shell/Margin/VBox/Header/Title
@onready var intro_label: RichTextLabel = $Control/Margin/Shell/Margin/VBox/Header/IntroLabel
@onready var identify_image: TextureRect = $Control/Margin/Shell/Margin/VBox/Content/ReferencePanel/Margin/VBox/ImageAspect/ImageFrame/IdentifyImage
@onready var source_label: Label = $Control/Margin/Shell/Margin/VBox/Content/ReferencePanel/Margin/VBox/SourceLabel
@onready var prompt_label: Label = $Control/Margin/Shell/Margin/VBox/Content/ChoiceColumn/PromptLabel
@onready var grid: GridContainer = $Control/Margin/Shell/Margin/VBox/Content/ChoiceColumn/OptionsGrid
@onready var helper_label: Label = $Control/Margin/Shell/Margin/VBox/Content/ChoiceColumn/HelperLabel
@onready var submit_button: Button = $Control/Margin/Shell/Margin/VBox/Actions/SubmitButton
@onready var skip_button: Button = $Control/Margin/Shell/Margin/VBox/Actions/SkipButton

var choice_card_scene: PackedScene = preload("res://scenes/ui/IdentifyChoiceCard.tscn")
var chips: Array[Button] = []
var _choice_group: ButtonGroup = ButtonGroup.new()
var _selected_species_name := ""

func _ready() -> void:
	submit_button.pressed.connect(submit_identification)
	skip_button.pressed.connect(func(): skipped.emit())
	_update_submit_state()

func setup(intro_text: String, texture: Texture2D, source_text: String, choices: Array[String], choice_texture_map: Dictionary, allow_skip: bool = true) -> void:
	title_label.text = "Identify the Reef"
	intro_label.text = intro_text
	identify_image.texture = texture
	source_label.text = source_text
	skip_button.visible = allow_skip
	prompt_label.text = "Choose the closest coral match"
	
	for child in grid.get_children():
		child.queue_free()
	chips.clear()
	_choice_group = ButtonGroup.new()
	_selected_species_name = ""
	grid.columns = 2 if choices.size() > 2 else max(1, choices.size())
	
	for species in choices:
		var chip = choice_card_scene.instantiate()
		grid.add_child(chip)
		chip.button_group = _choice_group
		var choice_texture: Texture2D = choice_texture_map.get(species)
		chip.setup(species, choice_texture)
		chip.toggled.connect(_on_chip_toggled.bind(species))
		chips.append(chip)
	
	_update_submit_state()

func _on_chip_toggled(pressed: bool, species: String) -> void:
	if pressed:
		_selected_species_name = species
	else:
		if _selected_species_name == species:
			_selected_species_name = ""
	_update_submit_state()

func _update_submit_state() -> void:
	var is_ready := not _selected_species_name.is_empty()
	
	submit_button.disabled = not is_ready
	identify_ready.emit(is_ready)
	
	if _selected_species_name.is_empty():
		submit_button.text = "Choose a coral"
		helper_label.text = "Select one option, then confirm."
	else:
		submit_button.text = "Confirm %s" % _selected_species_name
		helper_label.text = "Selected: %s" % _selected_species_name

func _selected_species() -> Array[String]:
	if _selected_species_name.is_empty():
		return []
	return [_selected_species_name]

func submit_identification() -> void:
	submitted.emit(_selected_species())
