## One-time tooltip shown when a stressor species first appears.
## Persisted via AppController.mark_stressor_tooltip_shown().
extends Control

signal dismissed

func setup(stressor_id: String, stressor_name: String, counter_hint: String) -> void:
	$Panel/VBox/TitleLabel.text = "⚠ THREAT DETECTED"
	$Panel/VBox/BodyLabel.text = "%s is disrupting your reef." % stressor_name
	$Panel/VBox/HintLabel.text = counter_hint if counter_hint != "" else "Net it or introduce a natural predator."

func _ready() -> void:
	$Panel/VBox/DismissButton.pressed.connect(func(): dismissed.emit())
