extends Node2D

func _physics_process(delta: float) -> void:
	if (Input.is_action_just_pressed("portal")):
		get_tree().change_scene_to_file("res://Portal/nivelPrueba/nivel.tscn")
