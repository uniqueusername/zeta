extends Node3D

@export var p: CharacterBody3D
@export var camera: Camera3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed: float = 10

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_movement(delta)
	p.move_and_slide()

func handle_gravity(delta: float):
	if not p.is_on_floor():
		p.velocity.y -= gravity * delta

func handle_movement(delta: float):
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var camera_rotation: float = fmod(-camera.rotation.y, 2*PI)
	p.velocity.x = input_dir.rotated(camera_rotation).x * speed
	p.velocity.z = input_dir.rotated(camera_rotation).y * speed
