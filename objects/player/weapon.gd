extends Area3D

func _input(event: InputEvent):
	if event.is_action_pressed("attack"):
		if has_overlapping_bodies():
			get_overlapping_bodies()[0].hit()
			
		if has_overlapping_areas():
			get_overlapping_areas()[0].untether()
