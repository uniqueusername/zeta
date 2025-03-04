extends CSGCylinder3D

@export var callback: bool = false

func break_tether() -> void:
	if callback: manager.show_next_dialogue()
	queue_free()
