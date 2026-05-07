extends CanvasLayer

func _ready() -> void:
	var panel := ColorRect.new()
	panel.color = Color(0, 0, 0, 0.42)
	panel.position = Vector2(18, 18)
	panel.size = Vector2(510, 104)
	add_child(panel)

	var label := Label.new()
	label.position = Vector2(34, 30)
	label.text = "Echoes in the Fog\nWASD/Arrows: move    Shift: sprint/noisy    Left click: throw distraction    F3: debug\nGoal: reach the green extraction zone. Guards track beliefs, not perfect truth."
	label.add_theme_font_size_override("font_size", 16)
	add_child(label)
