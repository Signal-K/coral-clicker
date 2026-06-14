extends Control

func _draw() -> void:
	var c: Vector2 = size / 2.0
	var r: float = min(size.x, size.y) / 2.0 - 2.0
	draw_arc(c, r, 0.0, TAU, 64, Color(0.251, 0.412, 0.427, 1.0), 2.0, true)
	draw_circle(c, r - 4.0, Color(0.020, 0.137, 0.173, 1.0))
	draw_arc(c, r * 0.6, 0.0, TAU, 32, Color(0.322, 0.949, 0.961, 0.2), 1.0, true)
	draw_circle(c, 4.0, Color(0.322, 0.949, 0.961, 1.0))
