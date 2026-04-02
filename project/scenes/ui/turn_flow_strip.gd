extends HBoxContainer

signal turn_pressed
signal shop_pressed

@onready var step_label: Label = $StepLabel
@onready var next_turn_button: Button = $NextTurnButton
@onready var shop_button: Button = $ShopButton

func _ready() -> void:
	next_turn_button.pressed.connect(_on_end_turn_pressed)
	shop_button.pressed.connect(func(): shop_pressed.emit())

func set_step(step: int) -> void:
	if step == 1:
		step_label.text = "Reef Loop: Choose your fish"
	elif step == 2:
		step_label.text = "Reef Loop: Resolve the reef"

func set_disabled(disabled: bool) -> void:
	next_turn_button.disabled = disabled
	shop_button.disabled = disabled

func _on_end_turn_pressed() -> void:
	turn_pressed.emit()
