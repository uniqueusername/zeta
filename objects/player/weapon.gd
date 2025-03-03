extends Area3D

@export var movement: Node3D

#func _input(event: InputEvent):
	#if event.is_action_pressed("attack"):
		#if has_overlapping_bodies():
			#if not get_overlapping_bodies()[0].tethered:
				#get_overlapping_bodies()[0].hit()
				#movement.instant_redirect()
			#
		#if has_overlapping_areas():
			#get_overlapping_areas()[0].untether()
			#movement.instant_redirect()
			
func _input(event: InputEvent):
	if event.is_action_pressed("attack"):
		if has_overlapping_bodies():
			get_overlapping_bodies()[0].break_tether()
			movement.instant_redirect()
