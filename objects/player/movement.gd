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

## other
const jump_vel: float = 3
const dash_vel: float = 25

func _physics_process(delta) -> void:
	var input_dir: Vector2 = Input.get_vector("left", "right", "backward", "forward")
	var movement_dir: Vector2 = _calculate_movement_dir(input_dir)
	
	if not p.is_on_floor(): _apply_gravity(delta)
	_handle_walking(movement_dir, delta)
	p.move_and_slide()
	
	_update_speed_label()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and p.is_on_floor():
		_jump()
		
	if event.is_action_pressed("dash"):
		_dash(Input.get_axis("left", "right"))

func _apply_gravity(delta: float) -> void:
	p.velocity.y -= gravity * delta

func _handle_walking(movement_dir: Vector2, delta: float) -> void:
	var curr_vel: Vector2 = _get_2d_player_vel()
	
	if movement_dir:
		walking.emit()
		_set_player_vel_from_2d(curr_vel.move_toward(movement_dir * max_walk_vel, walk_accel * delta))
	else:
		not_walking.emit()
		_set_player_vel_from_2d(curr_vel.move_toward(Vector2.ZERO, walk_accel * delta))

func _jump():
	p.velocity.y += jump_vel
	
func _dash(dash_dir: float):
	var input: Vector2 = Vector2(dash_dir, 0)
	var new_vel: Vector2 = _get_2d_player_vel() + _calculate_movement_dir(input) * dash_vel
	_set_player_vel_from_2d(new_vel)
	camera.dash(dash_dir)

func _update_speed_label():
	if speed_label: speed_label.text = str(int(_get_2d_player_vel().length()))

func _get_2d_player_vel() -> Vector2:
	return Vector2(p.velocity.x, -p.velocity.z)

func _set_player_vel_from_2d(vel: Vector2) -> void:
	p.velocity = Vector3(vel.x, p.velocity.y, -vel.y)

func _calculate_movement_dir(input: Vector2) -> Vector2:
	return input.rotated(camera.rotation.y)
