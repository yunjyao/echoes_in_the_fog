extends Node2D

var radius := 120.0
var label := "Noise"
var lifetime := 0.55
var _age := 0.0

func _process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var t := clamp(_age / lifetime, 0.0, 1.0)
	var alpha := 1.0 - t
	draw_arc(Vector2.ZERO, radius * t, 0.0, TAU, 80, Color(0.50, 0.75, 1.0, 0.45 * alpha), 3.0)
	draw_circle(Vector2.ZERO, 4.0, Color(0.70, 0.90, 1.0, 0.9 * alpha))
	draw_string(ThemeDB.fallback_font, Vector2(10, -10), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.78, 0.88, 1.0, alpha))
