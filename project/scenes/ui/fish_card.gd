extends PanelContainer

signal feed_pressed
signal net_pressed
signal starvation_animation_finished

@onready var anim_sprite: AnimatedSprite2D = $Margin/VBox/SpriteContainer/AnimatedSprite2D
@onready var species_label: Label = $Margin/VBox/SpeciesLabel
@onready var pop_label: Label = $Margin/VBox/SpriteContainer/PopBadge/PopLabel
@onready var trigger_label: Label = $Margin/VBox/TriggerLabel
@onready var extinct_label: Label = $Margin/VBox/ExtinctLabel
@onready var feed_button: Button = $Margin/VBox/ActionRow/FeedButton
@onready var net_button: Button = $Margin/VBox/ActionRow/NetButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var species: String = ""
var is_extinct := false
var _extinct_flash_tween: Tween = null

func _ready() -> void:
	feed_button.pressed.connect(func(): feed_pressed.emit())
	net_button.pressed.connect(func(): net_pressed.emit())
	_ensure_starvation_animation()
	animation_player.animation_finished.connect(_on_animation_finished)


func _gui_input(event: InputEvent) -> void:
	if not is_extinct:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_show_extinct_label()

func setup(p_species: String, frames: SpriteFrames) -> void:
	species = p_species
	species_label.text = species
	anim_sprite.sprite_frames = frames
	anim_sprite.play("default")

func update_pop(pop: int) -> void:
	pop_label.text = str(pop)

func set_disabled(disabled: bool) -> void:
	feed_button.disabled = disabled
	net_button.disabled = disabled


func set_net_state(disabled: bool, triggers_remaining: int, max_triggers: int) -> void:
	net_button.disabled = disabled
	trigger_label.text = "Net %d/%d" % [triggers_remaining, max_triggers]
	trigger_label.modulate = Color(1, 1, 1, 0.5) if disabled else Color(1, 1, 1, 1)


func set_extinct_state(extinct: bool) -> void:
	is_extinct = extinct
	feed_button.disabled = feed_button.disabled or extinct
	net_button.disabled = net_button.disabled or extinct
	modulate = Color(0.55, 0.55, 0.55, 0.9) if extinct else Color(1, 1, 1, 1)
	if not extinct:
		extinct_label.visible = false


func play_starvation_death() -> void:
	if animation_player == null:
		starvation_animation_finished.emit()
		return
	modulate = Color(1, 1, 1, 1)
	animation_player.stop()
	animation_player.play("starve_death")


func reset_visual_state() -> void:
	if animation_player:
		animation_player.stop()
	modulate = Color(0.55, 0.55, 0.55, 0.9) if is_extinct else Color(1, 1, 1, 1)


func _show_extinct_label() -> void:
	if _extinct_flash_tween:
		_extinct_flash_tween.kill()
	extinct_label.visible = true
	extinct_label.modulate.a = 1.0
	_extinct_flash_tween = create_tween()
	_extinct_flash_tween.tween_interval(1.0)
	_extinct_flash_tween.tween_property(extinct_label, "modulate:a", 0.0, 0.25)
	_extinct_flash_tween.finished.connect(func():
		extinct_label.visible = false
		extinct_label.modulate.a = 1.0
	)


func _ensure_starvation_animation() -> void:
	if animation_player == null or animation_player.has_animation("starve_death"):
		return
	var library: AnimationLibrary = null
	if animation_player.has_animation_library(""):
		library = animation_player.get_animation_library("")
	if library == null:
		library = AnimationLibrary.new()
		animation_player.add_animation_library("", library)
	var animation := Animation.new()
	animation.length = 1.6

	var modulate_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(modulate_track, NodePath(".:modulate"))
	animation.track_insert_key(modulate_track, 0.0, Color(1, 1, 1, 1))
	animation.track_insert_key(modulate_track, 0.5, Color(0.55, 0.55, 0.55, 1))
	animation.track_insert_key(modulate_track, 0.9, Color(0.55, 0.55, 0.55, 1))
	animation.track_insert_key(modulate_track, 1.6, Color(0.55, 0.55, 0.55, 0))

	var pos_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(pos_track, NodePath("Margin/VBox/SpriteContainer/AnimatedSprite2D:position"))
	animation.track_insert_key(pos_track, 0.0, Vector2(52, 36))
	animation.track_insert_key(pos_track, 0.9, Vector2(52, 44))
	animation.track_insert_key(pos_track, 1.6, Vector2(52, 58))

	library.add_animation("starve_death", animation)


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name != "starve_death":
		return
	reset_visual_state()
	starvation_animation_finished.emit()
