extends Node3D

# signals
signal walking
signal not_walking

# references
@export var p: CharacterBody3D
@export var camera: Camera3D
@export var speed_label: Label
@export var hook_ray: RayCast3D
@export var slide_audio: AudioStreamPlayer3D
@export var slide_stop_audio: AudioStreamPlayer3D
@export var land_audio: AudioStreamPlayer3D

# constants
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") * 4

## walking
const walk_accel: float = 150
const max_walk_vel: float = 15

## sliding
const slide_accel: float = 15
const slide_friction: float = 70
const slide_turn_allowance: float = 0.8

## dashing
const dash_vel: float = 35
const slide_dash_multiplier: float = 0.35
const dash_cooldown: float = 1

## hook
const hook_vel: float = 65
const hook_vert_multiplier: float = 1.3
const hookable_color: Color = Color(0.25, 0.25, 1)

## other
const jump_vel: float = 15
const air_strafe_mult: float = 0.3
const redirect_multiplier: float = 1
const default_fov: float = 75
const slide_fov: float = 100

# variables
var sliding: bool = false
var hooked: bool = false
var in_air_last_frame: bool = false

func _physics_process(delta) -> void:
	var input_dir: Vector2 = Input.get_vector("left", "right", "backward", "forward")
	var movement_dir: Vector2 = _calculate_movement_dir(input_dir)
	
	_apply_gravity(delta)
	if not sliding: _handle_walking(movement_dir, delta)
	else: _handle_sliding(movement_dir, delta)
	if hooked: _handle_hook(delta)
	if Input.is_action_just_pressed("parry"): instant_redirect()
	p.move_and_slide()
	
	_update_speed_label()
	
	if not p.is_on_floor() and slide_audio.playing:
		slide_audio.stop()
		slide_stop_audio.play()
		
	if in_air_last_frame and p.is_on_floor():
		if sliding: slide_audio.play()
		else: land_audio.play()
		
	in_air_last_frame = not p.is_on_floor()
	
func _process(delta) -> void:
	if hook_ray.is_colliding():
		$hook/CenterContainer/TextureRect.color = hookable_color
	else:
		$hook/CenterContainer/TextureRect.color = Color.WHITE
	
	if (hooked): _handle_hook_graphics(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and p.is_on_floor():
		_jump()
		
	if event.is_action_pressed("dash") and $dash_cooldown.is_stopped():
		_dash(Input.get_axis("left", "right"))
		
	if event.is_action_pressed("slide"):
		_set_slide(true)
	if event.is_action_released("slide"):
		_set_slide(false)
		
	if event.is_action_pressed("fire_hook"):
		_fire_hook()
	if event.is_action_released("fire_hook"):
		_release_hook()

func _apply_gravity(delta: float) -> void:
	p.velocity.y -= gravity * delta

func _handle_walking(movement_dir: Vector2, delta: float) -> void:
	var multiplier: float = 1 if p.is_on_floor() else air_strafe_mult
	
	if movement_dir:
		if p.is_on_floor():
			walking.emit()
		else:
			not_walking.emit()
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
		
func _handle_hook(delta: float) -> void:
	var hook_vec: Vector3 = ($hook.global_position - camera.global_position).normalized() * hook_vel * delta
	hook_vec.y *= hook_vert_multiplier
	p.velocity += hook_vec
	
func _handle_hook_graphics(delta: float) -> void:
	$hook/chain.global_position = $hook.global_position
	
	if (camera.global_position.cross(Vector3.UP) != Vector3.ZERO):
		$hook/chain.transform = $hook/chain.global_transform.looking_at(camera.global_position, Vector3.UP, true)
	$hook/chain.rotation.x += PI/2
	var dist: float = ($hook/chain.global_position - camera.global_position).length()
	$hook/chain.height = dist
	$hook/chain.global_position = $hook/chain.global_position.move_toward(p.global_position, dist/2)
	$hook/chain.material.uv1_scale.y = dist * 4

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
		_tween_camera_fov(default_fov)
		slide_audio.stop()
		slide_stop_audio.play()
	elif p.is_on_floor():
		self.sliding = true
		not_walking.emit()
		_tween_player_height(0.8)
		_tween_camera_fov(slide_fov)
		slide_audio.play()

func _update_speed_label():
	if speed_label: speed_label.text = str(int(p.velocity.length()))

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
	
func _tween_camera_fov(fov: float) -> void:
	var tween: Tween = self.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(camera, "fov", fov, 0.3)
	
func instant_redirect() -> void:
	p.velocity = camera.global_transform.basis.z.normalized() * p.velocity.length() * redirect_multiplier

func _fire_hook() -> void:
	if (hook_ray.is_colliding()):
		hooked = true
		$hook.global_position = hook_ray.get_collision_point()
		$hook/chain.visible = true
		$hook/hook.play()
		$hook/hook_hit.play()

func _release_hook() -> void:
	hooked = false
	$hook/chain.visible = false
	$hook/hook.stop()
