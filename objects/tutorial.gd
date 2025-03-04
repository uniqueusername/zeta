extends Control

func _ready() -> void:
	_bloop()

func _jump_trigger(body: Node3D) -> void:
	_bloop()
	$AnimatedSprite2D.animation = "jump"

func _bloop() -> void:
	scale = Vector2(4, 4)
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2, 2), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

func _after_jump(body: Node3D) -> void:
	visible = false
