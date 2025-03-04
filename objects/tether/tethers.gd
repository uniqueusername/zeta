extends Node3D

var all_broken: bool = false

func _physics_process(delta: float) -> void:
	if not all_broken and get_child_count() == 0: 
		all_broken = true
		manager._enable_door()
