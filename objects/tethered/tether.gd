extends Area3D

func untether() -> void:
	get_parent().untether()
	visible = false
