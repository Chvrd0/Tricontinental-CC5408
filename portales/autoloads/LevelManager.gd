extends Node

@export var main_menu: PackedScene
@export var credits: PackedScene
@export var levels: Array[PackedScene] = []



var current_level = -1



func go_next_level():
	print("Loading level ", current_level)
	current_level += 1
	if levels.size() > current_level:
		print("Yes")
		print("Level", levels[current_level])
		get_tree().change_scene_to_packed(levels[current_level])
	else:
		go_to_credits()
		

func go_to_main_menu():
	if main_menu:
		get_tree().change_scene_to_packed(main_menu)
		current_level = -1
func go_to_credits():
	if credits:
		get_tree().change_scene_to_packed(credits)

func _dead(pause_menu : CanvasLayer):
	pause_menu.visible = not pause_menu.visible
