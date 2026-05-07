extends Node2D

func _draw() -> void:
	for x in range(0, 1281, 40):
		draw_line(Vector2(x, 0), Vector2(x, 720), Color(1, 1, 1, 0.035), 1.0)
	for y in range(0, 721, 40):
		draw_line(Vector2(0, y), Vector2(1280, y), Color(1, 1, 1, 0.035), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(1115, 45), "EXTRACT", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.70, 1.0, 0.78, 0.95))

func _ready() -> void:
	queue_redraw()
