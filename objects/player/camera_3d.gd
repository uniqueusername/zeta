extends Camera3D

const SENSITIVITY: float = 0.003;
const AUTO_ROTATE_RATE: float = 0.01
const DASH_ROTATION: float = 0.02

func _ready() -> void:
	$AnimationPlayer.current_animation = "bob"
	$AnimationPlayer.stop()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.x += event.get_screen_relative().y * -1 * SENSITIVITY;
		rotation.y += event.get_screen_relative().x * -1 * SENSITIVITY;

func _on_movement_walking() -> void:
	$AnimationPlayer.play()

func _on_movement_not_walking() -> void:
	$AnimationPlayer.stop()
	
func _rotate_to_base() -> void:
	var new_rot: Vector3 = rotation
	new_rot.z = 0
	
	var tween: Tween = self.create_tween()


func dash(dash_dir: float) -> void:
	var tween: Tween = self.create_tween()
	var new_rot: Vector3 = rotation
	new_rot.z = DASH_ROTATION * dash_dir
	tween.tween_property(self, "rotation", new_rot, 0.1)
	
	new_rot.z = 0
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "rotation", new_rot, 0.3)
