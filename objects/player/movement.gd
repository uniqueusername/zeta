extends Node3D

# signals
signal walking
signal not_walking

# references
@export var p: CharacterBody3D
@export var camera: Camera3D
@export var speed_label: Label

# constants
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

## walking
const walk_accel: float = 150
const max_walk_vel: float = 15

## sliding
const slide_accel: float = 25
const slide_friction: float = 50
const slide_turn_allowance: float = 0.8

## dashing
const dash_vel: float = 25
const slide_dash_multiplier: float = 0.35
const dash_cooldown: float = 1

## other
const jump_vel: float = 3
const air_strafe_mult: float = 0.5

# variables
var sliding: bool = false

func _physics_process(delta) -> void:
	var input_dir: Vector2 = Input.get_vector("left", "right", "backward", "forward")
	var movement_dir: Vector2 = _calculate_movement_dir(input_dir)
	
	if not p.is_on_floor(): _apply_gravity(delta)
	if not sliding: _handle_walking(movement_dir, delta)
	else: _handle_sliding(movement_dir, delta)
	p.move_and_slide()
	
	_update_speed_label()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and p.is_on_floor():
		_jump()
		
	if event.is_action_pressed("dash") and $dash_cooldown.is_stopped():
		_dash(Input.get_axis("left", "right"))
		
	if event.is_action_pressed("slide"):
		_set_slide(true)
	if event.is_action_released("slide"):
		_set_slide(false)

func _apply_gravity(delta: float) -> void:
	p.velocity.y -= gravity * delta

func _handle_walking(movement_dir: Vector2, delta: float) -> void:
	var multiplier: float = 1 if p.is_on_floor() else air_strafe_mult
	
	if movement_dir:
		walking.emit()
		_set_player_vel_from_2d(_get_2d_player_vel().move_toward(movement_dir * max_walk_vel, walk_accel * multiplier * delta))
	else:
		not_walking.emit()
		_set_player_vel_from_2d(_get_2d_player_vel().move_toward(Vector2.ZERO, walk_accel * multiplier * delta))

func _handle_sliding(movement_dir: Vector2, delta: float) -> void:
	var curr_vel: Vector2 = _get_2d_player_vel()
	var normalized_dot: float = (curr_vel.normalized().dot(movement_dir.normalized()) + 0.1) ** 10
	
	if movement_dir and normalized_dot > 0:
		_set_player_vel_from_2d(curr_vel.move_toward(curr_vel + movement_dir * normalized_dot, slide_accel * delta))
	else:
		_set_player_vel_from_2d(curr_vel.move_toward(Vector2.ZERO, slide_friction * delta))
		
	if _get_2d_player_vel().length() <= max_walk_vel:
		_set_slide(false)

func _jump():
	p.velocity.y += jump_vel
	
func _dash(dash_dir: float):
	var input: Vector2 = Vector2(dash_dir, 0)
	var multiplier: float = 1 if not sliding else slide_dash_multiplier
	var new_vel: Vector2 = _get_2d_player_vel() + _calculate_movement_dir(input) * dash_vel * multiplier
	$dash_cooldown.start(dash_cooldown)
	
	_set_player_vel_from_2d(new_vel)
	camera.dash(dash_dir)

func _set_slide(sliding: bool):
	if not sliding and _get_2d_player_vel().length() <= max_walk_vel:
		self.sliding = false
		_tween_player_height(1)
	else:
		self.sliding = true
		not_walking.emit()
		_tween_player_height(0.8)

func _update_speed_label():
	if speed_label: speed_label.text = str(int(_get_2d_player_vel().length()))

func _get_2d_player_vel() -> Vector2:
	return Vector2(p.velocity.x, -p.velocity.z)

func _set_player_vel_from_2d(vel: Vector2) -> void:
	p.velocity = Vector3(vel.x, p.velocity.y, -vel.y)

func _calculate_movement_dir(input: Vector2) -> Vector2:
	return input.rotated(camera.rotation.y)
	
func _tween_player_height(height: float) -> void:
	var tween: Tween = self.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(p, "scale:y", height, 0.3)
