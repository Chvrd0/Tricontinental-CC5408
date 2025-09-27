extends Node2D

func _ready() -> void:
	print(get_tree().get_nodes_in_group("portalSalida").size())
