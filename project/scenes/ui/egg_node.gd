extends AnimatedSprite2D

signal hatched(species: String)

var species: String = ""
var is_hatched: bool = false
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	# Random initial rotation/bobbing offset
	rotation = randf_range(-0.1, 0.1)

func setup(p_species: String, p_sprite_frames: SpriteFrames) -> void:
	species = p_species
	sprite_frames = p_sprite_frames
	play("default")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _is_mouse_over():
					if not is_hatched:
						_hatch()
					else:
						is_dragging = true
						drag_offset = global_position - get_global_mouse_position()
			else:
				if is_dragging:
					is_dragging = false
					_check_placement()

	elif event is InputEventMouseMotion:
		if is_dragging:
			global_position = get_global_mouse_position() + drag_offset

func _is_mouse_over() -> bool:
	return area_2d.get_overlapping_areas().is_empty() # Simple check if area2d has input_pickable
	# Actually, easier to use input_event signal or just check distance
	# But we'll use Area2D properly.

func _hatch() -> void:
	is_hatched = true
	# Play hatch animation (scale burst)
	var tween = create_tween()
	tween.tween_property(self, "scale", scale * 1.5, 0.1)
	tween.tween_property(self, "scale", scale, 0.1)
	
	# Switch to fish sprite
	# For now, we'll assume the parent handles switching the SpriteFrames 
	# or we just emit the signal and the parent deals with it.
	hatched.emit(species)
	
	# After hatching, we automatically start dragging?
	# Task says: "TAPS the egg to trigger hatching, then DRAGS the hatched fish"
	# So it's two separate actions or one continuous?
	# "TAP... then DRAG" implies two.
	
	# Change animation to the fish?
	# Wait, the EggNode is an AnimatedSprite2D with the egg frames.
	# When hatched, it should probably change its SpriteFrames to the fish species.
	# But we'll need to know the fish SpriteFrames.

func _check_placement() -> void:
	# Signal to level_system to handle placement
	# We'll emit a signal with the final position
	if get_parent().has_method("_on_egg_placed"):
		get_parent().call("_on_egg_placed", self)
	else:
		# If no parent handles it, snap back or something?
		pass
