extends Node2D
var linkPortal: Vector2
var link: Dictionary = Dictionary()

func _ready() -> void:
	if self.name == "Portal":
		self.name = "Portal1"
	var entrada = get_tree().get_nodes_in_group("portalEntrada")
	var salida = get_tree().get_nodes_in_group("portalSalida")
	
	for i in range (entrada.size()):
		print("Linkeado portal entrada ", i + 1, " Posiciones: ", entrada[i].position, " y ",salida[i].position)
		linkPortal = salida[i].position
		link["Portal"+str(i+1)] = linkPortal
		

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		print("Jugador entro al portal")
		area.get_parent().position = link[self.name]
		

		
