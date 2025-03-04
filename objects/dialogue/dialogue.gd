extends MarginContainer

@onready var label: Label = $MarginContainer/HBoxContainer/ColorRect/MarginContainer/ColorRect/MarginContainer/ColorRect/MarginContainer/Label
@onready var timer: Timer = $Timer
@export var callback: bool = false

func _ready() -> void:
	label.visible_ratio = 0
	
func _process(delta: float) -> void:
	label.visible_ratio += delta / label.text.length() * 25
	if label.visible_ratio == 1: timer.stop()

func _on_timer_timeout() -> void:
	$AudioStreamPlayer2D.play()

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("attack") or event.is_action_pressed("advance")) and label.visible_ratio < 1: label.visible_ratio = 1
	elif (event.is_action_pressed("attack") or event.is_action_pressed("advance")) and label.visible_ratio == 1: 
		if callback: manager.show_next_dialogue()
		queue_free()
