extends Control

func _ready() -> void:
	$Panel/VBox/Header/CloseButton.pressed.connect(queue_free)
	_load_settings()

func _load_settings() -> void:
	var sound_on: bool = ProjectSettings.get_setting("coral/sound_enabled", true)
	$Panel/VBox/SoundRow/SoundToggle.button_pressed = sound_on

	var haptic_on: bool = ProjectSettings.get_setting("coral/haptic_enabled", true)
	$Panel/VBox/HapticRow/HapticToggle.button_pressed = haptic_on

func _on_sound_toggled(on: bool) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not on)

func _on_haptic_toggled(_on: bool) -> void:
	pass  # Mobile haptic handled by MobileWeb autoload
