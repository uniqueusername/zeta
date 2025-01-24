extends Camera3D

const SENSITIVITY: float = 0.003;

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.x += event.get_screen_relative().y * -1 * SENSITIVITY;
		rotation.y += event.get_screen_relative().x * -1 * SENSITIVITY;
