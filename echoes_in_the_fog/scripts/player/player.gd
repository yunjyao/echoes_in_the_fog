extends CharacterBody2D

signal sound_emitted(position: Vector2, loudness: float, label: String)

@export var walk_speed := 170.0
@export var sprint_speed := 270.0
@export var quiet_noise_radius := 85.0
@export var sprint_noise_radius := 190.0

var _sound_cooldown := 0.0
var _body_radius := 13.0

func _ready() -> void:
	name = "Player"
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = _body_radius
	shape.shape = circle
	add_child(shape)

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1.0
	input_vector = input_vector.normalized()
	var sprinting := Input.is_key_pressed(KEY_SHIFT)
	var current_speed := sprint_speed if sprinting else walk_speed
	velocity = input_vector * current_speed
	move_and_slide()

	if input_vector.length() > 0.05:
		_sound_cooldown -= delta
		if _sound_cooldown <= 0.0:
			var radius := sprint_noise_radius if sprinting else quiet_noise_radius
			var label := "Sprint footsteps" if sprinting else "Footsteps"
			sound_emitted.emit(global_position, radius, label)
			_sound_cooldown = 0.22 if sprinting else 0.42
	else:
		_sound_cooldown = min(_sound_cooldown, 0.1)

	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, _body_radius, Color(0.35, 0.75, 1.0))
	draw_circle(Vector2.ZERO, 5.0, Color(0.85, 0.95, 1.0))
