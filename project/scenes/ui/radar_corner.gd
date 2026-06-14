extends Control

var _angle: float = 0.0

func _process(delta: float) -> void:
	_angle += delta * 1.2
	queue_redraw()

func _draw() -> void:
	var c: Vector2 = size / 2.0
	var r: float = min(size.x, size.y) / 2.0

	# Background
	draw_circle(c, r, Color(0.0, 0.063, 0.086, 0.85))

	# Concentric rings
	for i in [0.75, 0.5, 0.25]:
		draw_arc(c, r * i, 0.0, TAU, 48, Color(0.322, 0.949, 0.961, 0.12), 1.0, true)

	# Outer ring
	draw_arc(c, r - 1.0, 0.0, TAU, 64, Color(0.322, 0.949, 0.961, 0.3), 2.0, true)

	# Sweep arm — gradient line from centre outward
	var arm_end: Vector2 = c + Vector2(cos(_angle), sin(_angle)) * (r - 4.0)
	draw_line(c, arm_end, Color(0.322, 0.949, 0.961, 0.6), 2.0, true)

	# Fade trail (4 ghost lines behind the arm)
	for i in range(1, 5):
		var trail_angle: float = _angle - i * 0.15
		var trail_end: Vector2 = c + Vector2(cos(trail_angle), sin(trail_angle)) * (r - 4.0)
		draw_line(c, trail_end, Color(0.322, 0.949, 0.961, 0.12 / i), 1.5, true)

	# Centre dot
	draw_circle(c, 3.0, Color(0.322, 0.949, 0.961, 1.0))

	# Random blip dots (seeded by angle so they "move" slowly)
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for _i in range(5):
		var bx := rng.randf_range(0.2, 0.8) * size.x
		var by := rng.randf_range(0.2, 0.8) * size.y
		var dist := Vector2(bx, by).distance_to(c)
		if dist < r - 6.0:
			var alpha: float = 0.8 if fmod(_angle + rng.randf(), TAU) < 0.3 else 0.25
			draw_circle(Vector2(bx, by), 2.0, Color(0.322, 0.949, 0.961, alpha))
