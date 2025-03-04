extends CharacterBody3D

var health: int = 100

func hit(damage: float):
	if $iframe.is_stopped():
		health -= damage
		$iframe.start()

func _process(delta: float):
	$AspectRatioContainer/health.text = str(health)

func _on_kill_zone_body_entered(body: Node3D) -> void:
	manager.kill_player()

func _next_dialogue(body: Node3D) -> void:
	manager.show_next_dialogue()
