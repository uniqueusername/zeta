extends StaticBody3D

@export var camera: Camera3D

func _ready() -> void:
	transform = camera.transform
