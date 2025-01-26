extends Node3D

@export var p: CharacterBody3D
@export var camera: Camera3D

@export var max_speed: float = 15
@export var start_rate: float = 0.5
@export var stop_rate: float = 5 # aka friction

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var sliding: bool = false

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	if sliding: handle_movement_uncapped(delta)
	else: handle_movement(delta)
	
	p.move_and_slide()

func handle_gravity(delta: float):
	if not p.is_on_floor():
		p.velocity.y -= gravity * delta

func handle_movement(delta: float) -> void:
	var camera_rotation: float = fmod(-camera.rotation.y, 2*PI)
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	input_dir = input_dir.rotated(camera_rotation)
	
	var curr_velocity: Vector2 = Vector2(p.velocity.x, p.velocity.z)
	var velocity_target: Vector2 = input_dir * max_speed
	var new_velocity: Vector2
	if velocity_target:
		new_velocity = curr_velocity.move_toward(velocity_target, start_rate * 10)
	else:
		new_velocity = curr_velocity.move_toward(Vector2.ZERO, stop_rate)
	
	p.velocity.x = new_velocity.x
	p.velocity.z = new_velocity.y
	
func handle_movement_uncapped(delta: float) -> void:
	var camera_rotation: float = fmod(-camera.rotation.y, 2*PI)
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	input_dir = input_dir.rotated(camera_rotation)
	
	var curr_velocity: Vector2 = Vector2(p.velocity.x, p.velocity.z)
	var new_velocity: Vector2
	if input_dir:
		new_velocity = curr_velocity + input_dir * start_rate
	else:
		new_velocity = curr_velocity.move_toward(Vector2.ZERO, stop_rate)
	
	p.velocity.x = new_velocity.x
	p.velocity.z = new_velocity.y
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("slide"): sliding = true
	elif event.is_action_released("slide"): sliding = false
