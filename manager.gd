extends Node

var dialogue_array: Array = []
var curr_dialogue: int = 0
var curr_dialogue_box

var level_array: Array = []
var curr_level: int = 0

func _ready() -> void:
	var dir = DirAccess.open("res://objects/dialogue/dialogues/")
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file:
			dialogue_array.append(ResourceLoader.load(dir.get_current_dir() + "/" + file))
			file = dir.get_next()
			
	dir = DirAccess.open("res://levels/")
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file:
			level_array.append(ResourceLoader.load(dir.get_current_dir() + "/" + file))
			file = dir.get_next()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()
		
	if event.is_action_pressed("exit"):
		get_tree().quit()

func show_next_dialogue():
	if curr_dialogue == dialogue_array.size(): return
	if curr_dialogue_box != null: curr_dialogue_box.queue_free()
	curr_dialogue_box = dialogue_array[curr_dialogue].instantiate()
	add_child(curr_dialogue_box)
	curr_dialogue += 1

func next_level():
	curr_level += 1
	if curr_level == level_array.size(): return
	get_tree().change_scene_to_packed(level_array[curr_level])	
