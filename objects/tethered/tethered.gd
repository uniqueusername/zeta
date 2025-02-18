extends CharacterBody3D

enum MoveState {ROAM, ROAM_HOSTILE, WAIT, ATTACK, SLIDE}

var tethered: bool = true
var hostile_color: Color = Color.RED
var move_state: MoveState = MoveState.ROAM
var target: Vector3
var move_speed: float = 5
var track_rate: float = 0.3
var attack_range: float = 5
var attack_speed: float = 50

func _physics_process(delta: float) -> void:
	if move_state == MoveState.ROAM: _roam()
	elif move_state == MoveState.WAIT: _wait()
	elif move_state == MoveState.ROAM_HOSTILE: _roam_hostile()
	elif move_state == MoveState.ATTACK: _attack()
	elif move_state == MoveState.SLIDE: _slide()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()
	
func _process(delta: float) -> void:
	if $Timer.is_stopped():
		if tethered:
			if move_state == MoveState.ROAM: 
				move_state = MoveState.WAIT
				$Timer.start(3 )
			elif move_state == MoveState.WAIT: 
				_pick_target()
				move_state = MoveState.ROAM
				$Timer.start(1)
		else:
			if move_state == MoveState.SLIDE:
				move_state = MoveState.ROAM_HOSTILE
			elif move_state == MoveState.WAIT:
				move_state = MoveState.ATTACK
				
	if move_state == MoveState.ROAM_HOSTILE:
		if (%player.global_position - global_position).length() < attack_range:
			move_state = MoveState.WAIT
			$Timer.start(1)
			
func untether() -> void:
	tethered = false
	$MeshInstance3D.mesh.material.albedo_color = hostile_color
	move_state = MoveState.ROAM_HOSTILE

# called when the enemy is attacked
func hit() -> void:
	if tethered: return
	queue_free()

func _pick_target() -> void:
	randomize()
	target.x = randf_range(-1, 1)
	target.z = randf_range(-1, 1)
	
func _roam() -> void:
	velocity = target.normalized() * move_speed
	
func _roam_hostile() -> void:
	target = target.move_toward(%player.global_position - global_position, track_rate).normalized() * move_speed
	velocity = Vector3(target.x, velocity.y, target.z)
	
func _attack() -> void:
	target = (%player.global_position - global_position).normalized() * attack_speed
	velocity = target
	velocity.y = 5
	move_state = MoveState.SLIDE
	$Timer.start(3)
	
func _wait() -> void:
	target = velocity.move_toward(Vector3.ZERO, 5)
	velocity = Vector3(target.x, velocity.y, target.z)

func _slide() -> void:
	target = velocity.move_toward(Vector3.ZERO, 1)
	velocity = Vector3(target.x, velocity.y, target.z)
