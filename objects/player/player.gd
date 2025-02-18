extends CharacterBody3D

var health: int = 100

func hit(damage: float):
	if $iframe.is_stopped():
		health -= damage
		$iframe.start()

func _process(delta: float):
	$AspectRatioContainer/health.text = str(health)
