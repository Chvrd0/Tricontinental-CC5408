extends Node2D

var linkPortal: Vector2

func _ready() -> void:
	var entrada = get_tree().get_nodes_in_group("portalEntrada")
	var salida = get_tree().get_nodes_in_group("portalSalida")
	
	for i in range (salida.size()):
		print("Linkeado portal salida ", i + 1, " Posiciones: ", salida[i].position, " y ",entrada[i].position)
		linkPortal = entrada[i].position
