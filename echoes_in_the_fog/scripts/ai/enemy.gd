extends CharacterBody2D

@export var patrol_speed := 95.0
@export var investigate_speed := 125.0
@export var chase_speed := 165.0
@export var vision_range := 280.0
@export var vision_angle_degrees := 72.0
@export var memory_decay_per_second := 0.22
@export var hearing_confidence_scale := 0.78
@export var capture_distance := 24.0

var target_player: Node2D
var patrol_points: Array[Vector2] = []
var debug_enabled := true

var _body_radius := 15.0
var _facing := Vector2.LEFT
var _patrol_index := 0
var _belief_position := Vector2.ZERO
var _confidence := 0.0
var _state := "PATROL"
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("debug_drawables")
	collision_layer = 4
	collision_mask = 1
	_rng.randomize()
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = _body_radius
	shape.shape = circle
	add_child(shape)

func set_debug_enabled(value: bool) -> void:
	debug_enabled = value
	queue_redraw()

func _physics_process(delta: float) -> void:
	_update_perception(delta)
	_update_state()
	_apply_behavior(delta)
	queue_redraw()

func hear_sound(pos: Vector2, loudness: float) -> void:
	var distance := global_position.distance_to(pos)
	if distance > loudness:
		return
	var signal_strength := clamp(1.0 - distance / loudness, 0.0, 1.0)
	var noisy_guess := pos + Vector2(_rng.randf_range(-45, 45), _rng.randf_range(-45, 45)) * (1.0 - signal_strength)
	var new_confidence := signal_strength * hearing_confidence_scale
	if new_confidence > _confidence:
		_belief_position = noisy_guess
		_confidence = new_confidence

func _update_perception(delta: float) -> void:
	_confidence = max(0.0, _confidence - memory_decay_per_second * delta)
	if target_player == null:
		return
	if _can_see_player():
		_belief_position = target_player.global_position
		_confidence = 1.0

func _can_see_player() -> bool:
	var to_player := target_player.global_position - global_position
	if to_player.length() > vision_range:
		return false
	var angle := rad_to_deg(abs(_facing.angle_to(to_player.normalized())))
	if angle > vision_angle_degrees / 2.0:
		return false
	var space := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(global_position, target_player.global_position)
	params.collision_mask = 1
	params.exclude = [self]
	var hit := space.intersect_ray(params)
	return hit.is_empty()

func _update_state() -> void:
	if _confidence >= 0.82:
		_state = "CHASE"
	elif _confidence >= 0.20:
		_state = "INVESTIGATE"
	else:
		_state = "PATROL"

func _apply_behavior(_delta: float) -> void:
	var destination := global_position
	var speed := patrol_speed
	match _state:
		"CHASE":
			destination = _belief_position
			speed = chase_speed
		"INVESTIGATE":
			destination = _belief_position
			speed = investigate_speed
		_:
			destination = _current_patrol_point()
			speed = patrol_speed

	var to_destination := destination - global_position
	if to_destination.length() > 5.0:
		_facing = to_destination.normalized()
		velocity = _facing * speed
	else:
		velocity = Vector2.ZERO
		if _state == "PATROL" and patrol_points.size() > 0:
			_patrol_index = (_patrol_index + 1) % patrol_points.size()
		elif _state == "INVESTIGATE":
			_confidence = max(0.0, _confidence - 0.35)
	move_and_slide()
	_check_capture()

func _current_patrol_point() -> Vector2:
	if patrol_points.is_empty():
		return global_position
	return patrol_points[_patrol_index]

func _check_capture() -> void:
	if target_player == null:
		return
	if global_position.distance_to(target_player.global_position) <= capture_distance:
		print("Caught by %s. The AI followed its current belief." % name)

func _draw() -> void:
	var state_color := Color(0.85, 0.25, 0.20)
	if _state == "PATROL":
		state_color = Color(0.95, 0.75, 0.25)
	elif _state == "INVESTIGATE":
		state_color = Color(1.0, 0.48, 0.16)
	draw_circle(Vector2.ZERO, _body_radius, state_color)
	draw_line(Vector2.ZERO, _facing * 28.0, Color.WHITE, 2.0)

	if not debug_enabled:
		return
	_draw_vision_cone()
	if _confidence > 0.02:
		var local_belief := to_local(_belief_position)
		draw_circle(local_belief, 8.0 + 8.0 * _confidence, Color(0.4, 0.8, 1.0, 0.22))
		draw_line(Vector2.ZERO, local_belief, Color(0.4, 0.8, 1.0, 0.55), 1.5)
		draw_string(ThemeDB.fallback_font, Vector2(-35, -30), "%s %.0f%%" % [_state, _confidence * 100.0], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)

func _draw_vision_cone() -> void:
	var half_angle := deg_to_rad(vision_angle_degrees / 2.0)
	var left := _facing.rotated(-half_angle) * vision_range
	var right := _facing.rotated(half_angle) * vision_range
	var points := PackedVector2Array([Vector2.ZERO, left, right])
	draw_colored_polygon(points, Color(1.0, 0.9, 0.2, 0.10))
	draw_line(Vector2.ZERO, left, Color(1.0, 0.9, 0.2, 0.25), 1.0)
	draw_line(Vector2.ZERO, right, Color(1.0, 0.9, 0.2, 0.25), 1.0)
