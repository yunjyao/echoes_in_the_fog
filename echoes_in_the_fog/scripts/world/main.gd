extends Node2D

const PlayerScene := preload("res://scripts/player/player.gd")
const EnemyScene := preload("res://scripts/ai/enemy.gd")
const SoundEventScene := preload("res://scripts/world/sound_event.gd")
const HudScene := preload("res://scripts/ui/hud.gd")

var player: CharacterBody2D
var hud: CanvasLayer
var debug_enabled := true
var _debug_toggle_locked := false
var _mouse_throw_locked := false

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.06, 0.07, 0.08))
	_build_level()
	_spawn_player()
	_spawn_enemies()
	_spawn_hud()

func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_F3) and not _debug_toggle_locked:
		debug_enabled = !debug_enabled
		_debug_toggle_locked = true
		get_tree().call_group("debug_drawables", "set_debug_enabled", debug_enabled)
	elif not Input.is_key_pressed(KEY_F3):
		_debug_toggle_locked = false

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not _mouse_throw_locked:
		_mouse_throw_locked = true
		create_sound_event(get_global_mouse_position(), 380.0, "Thrown distraction")
	elif not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_mouse_throw_locked = false

func create_sound_event(pos: Vector2, loudness: float, label: String = "Noise") -> void:
	var sound := SoundEventScene.new()
	sound.global_position = pos
	sound.radius = loudness
	sound.label = label
	add_child(sound)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("hear_sound"):
			enemy.hear_sound(pos, loudness)

func _spawn_player() -> void:
	player = PlayerScene.new()
	player.global_position = Vector2(160, 560)
	player.sound_emitted.connect(create_sound_event)
	add_child(player)

func _spawn_enemies() -> void:
	var positions := [Vector2(880, 160), Vector2(980, 520), Vector2(580, 330)]
	for i in range(positions.size()):
		var enemy := EnemyScene.new()
		enemy.name = "Guard_%d" % (i + 1)
		enemy.global_position = positions[i]
		enemy.target_player = player
		enemy.patrol_points = _patrol_for_index(i)
		enemy.debug_enabled = debug_enabled
		add_child(enemy)

func _patrol_for_index(i: int) -> Array[Vector2]:
	match i:
		0:
			return [Vector2(780, 150), Vector2(1080, 150), Vector2(1080, 300), Vector2(780, 300)]
		1:
			return [Vector2(800, 480), Vector2(1120, 480), Vector2(1120, 610), Vector2(800, 610)]
		_:
			return [Vector2(440, 250), Vector2(650, 250), Vector2(650, 430), Vector2(440, 430)]

func _spawn_hud() -> void:
	hud = HudScene.new()
	add_child(hud)

func _build_level() -> void:
	_add_floor_grid()
	_add_wall(Rect2(Vector2(0, 0), Vector2(1280, 24)))
	_add_wall(Rect2(Vector2(0, 696), Vector2(1280, 24)))
	_add_wall(Rect2(Vector2(0, 0), Vector2(24, 720)))
	_add_wall(Rect2(Vector2(1256, 0), Vector2(24, 720)))
	_add_wall(Rect2(Vector2(260, 110), Vector2(60, 430)))
	_add_wall(Rect2(Vector2(430, 80), Vector2(330, 55)))
	_add_wall(Rect2(Vector2(420, 515), Vector2(360, 55)))
	_add_wall(Rect2(Vector2(610, 255), Vector2(70, 210)))
	_add_wall(Rect2(Vector2(850, 350), Vector2(280, 55)))
	_add_wall(Rect2(Vector2(980, 90), Vector2(55, 190)))
	_add_goal_zone(Rect2(Vector2(1110, 50), Vector2(95, 80)))

func _add_floor_grid() -> void:
	var grid := Node2D.new()
	grid.name = "FloorGrid"
	grid.set_script(load("res://scripts/world/floor_grid.gd"))
	add_child(grid)

func _add_wall(rect: Rect2) -> void:
	var wall := StaticBody2D.new()
	wall.name = "Wall"
	wall.collision_layer = 1
	wall.collision_mask = 0
	wall.position = rect.position + rect.size / 2.0
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = rect.size
	shape.shape = rectangle
	wall.add_child(shape)
	var visual := ColorRect.new()
	visual.color = Color(0.20, 0.22, 0.25)
	visual.size = rect.size
	visual.position = -rect.size / 2.0
	wall.add_child(visual)
	add_child(wall)

func _add_goal_zone(rect: Rect2) -> void:
	var goal := Area2D.new()
	goal.name = "ExtractionZone"
	goal.position = rect.position + rect.size / 2.0
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = rect.size
	shape.shape = rectangle
	goal.add_child(shape)
	var visual := ColorRect.new()
	visual.color = Color(0.10, 0.40, 0.28, 0.45)
	visual.size = rect.size
	visual.position = -rect.size / 2.0
	goal.add_child(visual)
	goal.body_entered.connect(func(body):
		if body == player:
			print("Mission complete: reached extraction zone.")
	)
	add_child(goal)
