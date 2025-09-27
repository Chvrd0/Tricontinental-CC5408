extends Node2D

var linkPortal: Vector2

func _ready() -> void:
	var entrada = get_tree().get_nodes_in_group("portalEntrada")
	var salida = get_tree().get_nodes_in_group("portalSalida")
	
	for i in range (entrada.size()):
		print("Linkeado portal ", i + 1, "Posiciones: ", entrada[i].position, " y ",salida[i].position)
		linkPortal = salida[i].position


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		print("Jugador entro al portal")
		area.get_parent().position = linkPortal
