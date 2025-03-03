extends Node3D

var dist: float = 25

func _physics_process(delta: float) -> void:
	if (global_position - %player.global_position).length() < dist:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector3(3, 3, 3), 0.2)
	else:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector3(1, 1, 1), 0.2)

func _on_static_body_3d_body_entered(body: Node3D) -> void:
	manager.next_level()
