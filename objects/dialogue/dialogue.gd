extends MarginContainer

@export var text: String
@export var image: Texture2D

func _ready() -> void:
	if text: $MarginContainer/HBoxContainer/ColorRect/MarginContainer/ColorRect/MarginContainer/ColorRect/MarginContainer/Label.text = text
	if image: $MarginContainer/HBoxContainer/TextureRect.texture = image
