extends CanvasLayer

signal advanced

@onready var root: Control = $Root
@onready var highlight: Panel = $Root/Highlight
@onready var panel: PanelContainer = $Root/Panel
@onready var title_label: Label = $Root/Panel/Margin/VBox/Title
@onready var body_label: RichTextLabel = $Root/Panel/Margin/VBox/Body
@onready var next_button: Button = $Root/Panel/Margin/VBox/NextButton


func _ready() -> void:
	visible = false
	next_button.pressed.connect(func(): advanced.emit())


func show_step(title: String, body: String, target: Control = null, show_button: bool = false, button_text: String = "Continue") -> void:
	title_label.text = title
	body_label.text = body
	next_button.visible = show_button
	next_button.text = button_text
	visible = true
	call_deferred("_refresh_target", target)


func hide_step() -> void:
	visible = false
	highlight.visible = false


func refresh_target(target: Control = null) -> void:
	call_deferred("_refresh_target", target)


func _refresh_target(target: Control = null) -> void:
	if target == null or not is_instance_valid(target) or not target.is_visible_in_tree():
		highlight.visible = false
		return

	var rect := target.get_global_rect()
	highlight.global_position = rect.position - Vector2(8.0, 8.0)
	highlight.size = rect.size + Vector2(16.0, 16.0)
	highlight.visible = true
