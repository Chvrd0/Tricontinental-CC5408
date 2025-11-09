extends Node2D
# 'linkPortal' ya no es necesario
var link: Dictionary = Dictionary()


func _physics_process(delta: float) -> void:
	if self.name == "Portal":
		self.name = "Portal1"
	var entrada = get_tree().get_nodes_in_group("portalEntrada")
	var salida = get_tree().get_nodes_in_group("portalSalida")
	
	for i in range (entrada.size()):
		# --- LÍNEA MODIFICADA ---
		# Almacenamos el NODO de salida, no solo su posición
		if len(entrada) == len(salida) and i < salida.size():
			link["Portal"+str(i+1)] = salida[i] 
		# --- FIN DE LÍNEA MODIFICADA ---

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		var player = area.get_parent()
		
		# --- SECCIÓN MODIFICADA ---
		if not link.has(self.name):
			return # No hay portal de salida vinculado
			
		var exit_portal = link[self.name] # 'exit_portal' es ahora el Nodo2D
		
		# 1. Teletransportar al jugador
		player.global_position = exit_portal.global_position
		
		# 2. Calcular la nueva dirección de gravedad
		# Vector2.DOWN (0, 1) rotado por la rotación del portal de salida
		var new_gravity_dir = Vector2.DOWN.rotated(exit_portal.rotation)
		
		# 3. Aplicar la nueva gravedad al jugador
		# (Usamos 'has_method' por seguridad)
		if player.has_method("set_gravity_direction"):
			player.set_gravity_direction(new_gravity_dir)
		# --- FIN DE SECCIÓN MODIFICADA ---
