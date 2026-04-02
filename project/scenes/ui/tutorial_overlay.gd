extends CanvasLayer

signal advanced

@onready var root: Control = $Root
@onready var highlight: Panel = $Root/Highlight
@onready var panel: PanelContainer = $Root/Panel
@onready var title_label: Label = $Root/Panel/Margin/VBox/Title
@onready var body_label: RichTextLabel = $Root/Panel/Margin/VBox/Body
@onready var next_button: Button = $Root/Panel/Margin/VBox/NextButton

var _panel_base_position := Vector2.ZERO


func _ready() -> void:
	visible = false
	_panel_base_position = panel.position
	next_button.pressed.connect(func(): advanced.emit())


func show_step(title: String, body: String, target: Node = null, show_button: bool = false, button_text: String = "Continue") -> void:
	title_label.text = title
	body_label.text = body
	next_button.visible = show_button
	next_button.text = button_text
	visible = true
	panel.modulate.a = 0.0
	panel.position = _panel_base_position + Vector2(0.0, 24.0)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.22)
	tween.tween_property(panel, "position", _panel_base_position, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	call_deferred("_refresh_target", target)


func hide_step() -> void:
	visible = false
	highlight.visible = false
	panel.position = _panel_base_position
	panel.modulate.a = 1.0


func refresh_target(target: Node = null) -> void:
	call_deferred("_refresh_target", target)


func _refresh_target(target: Node = null) -> void:
	if target == null or not is_instance_valid(target):
		highlight.visible = false
		return
	
	var control := target as Control
	if control == null or not control.is_visible_in_tree():
		highlight.visible = false
		return

	var rect := control.get_global_rect()
	highlight.global_position = rect.position - Vector2(8.0, 8.0)
	highlight.size = rect.size + Vector2(16.0, 16.0)
	highlight.visible = true
