extends CSGCylinder3D

func break_tether() -> void:
	manager.enable_door()
	queue_free()
