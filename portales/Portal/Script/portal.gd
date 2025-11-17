## Portal.gd
##
## Script encargado de gestionar los portales del juego.
## Permite enlazar portales de entrada y salida, teletransportar al jugador
## y actualizar la dirección de gravedad al atravesar un portal.


extends Node2D


# ===========================
# ==== VARIABLES ============
# ===========================

## Diccionario que almacena los enlaces entre portales.
## La clave es el nombre del portal de entrada (por ejemplo, "Portal1")
## y el valor es el nodo del portal de salida correspondiente.
var link: Dictionary = {}


# ===========================
# ==== PROCESO DE FÍSICA ====
# ===========================

## Lógica que se ejecuta en cada frame de física.
## Se encarga de vincular dinámicamente cada portal de entrada con su correspondiente salida.
##
## @param delta Tiempo transcurrido desde el último frame de física.
func _physics_process(delta: float) -> void:
	# Si este nodo se llama "Portal", le asignamos el nombre "Portal1" por defecto.
	if self.name == "Portal":
		self.name = "Portal1"
	
	# Obtenemos todas las instancias de portales de entrada y salida en la escena.
	var entrada = get_tree().get_nodes_in_group("portalEntrada")
	var salida = get_tree().get_nodes_in_group("portalSalida")
	
	# Vinculamos cada entrada con su salida correspondiente.
	for i in range(entrada.size()):
		# Aseguramos que haya el mismo número de entradas y salidas antes de vincular.
		if len(entrada) == len(salida) and i < salida.size():
			# Guardamos el *nodo* de salida (no solo su posición)
			link["Portal" + str(i + 1)] = salida[i]


func play_zap() -> void:
	var effect = $ZapEffect
	if effect == null:
		# No effect node; nothing to do.
		return
	if effect is GPUParticles2D:
		# restart the burst
		effect.emitting = false
		await get_tree().process_frame
		effect.emitting = true

		# attempt to read 'lifetime' from the particle node if it exists
		var wait_time: float = 0.25
		var props := effect.get_property_list()
		for p in props:
			if p.has("name") and p.name == "lifetime":
				# use get(...) to safely read it
				var val = effect.get("lifetime")
				if typeof(val) == TYPE_FLOAT or typeof(val) == TYPE_INT:
					wait_time = float(val)
				break

		# wait for the particle's lifetime (small margin added)
		await get_tree().create_timer(wait_time + 0.02).timeout
		return


# ===========================
# ==== EVENTOS DE ÁREA ======
# ===========================

## Se ejecuta cuando un área (por ejemplo, el cuerpo del jugador) entra en el área de detección del portal.
##
## @param area El área que ha ingresado (generalmente un Area2D del jugador).
func _on_area_2d_area_entered(area: Area2D) -> void:
	# Verificamos si el objeto que entra pertenece al grupo "player"
	if area.get_parent().is_in_group("player"):
		var player = area.get_parent()
		
		# Si el portal actual no tiene un enlace de salida, no hacemos nada.
		if not link.has(self.name):
			return
		
		# Obtenemos el portal de salida vinculado.
		var exit_portal: Node2D = link[self.name]
		
		await play_zap()
		player.visible = false
		
		# --- 1. TELETRANSPORTACIÓN ---
		# Movemos al jugador a la posición global del portal de salida.
		player.global_position = exit_portal.global_position
		
		# --- 2. NUEVA DIRECCIÓN DE GRAVEDAD ---
		# Calculamos la nueva dirección de gravedad según la rotación del portal de salida.
		# Por convención, Vector2.DOWN (0, 1) representa la gravedad hacia abajo;
		# se rota en función del ángulo del portal.
		var new_gravity_dir := Vector2.DOWN.rotated(exit_portal.rotation)
		
		# --- 3. ACTUALIZACIÓN DE GRAVEDAD ---
		# Llamamos al método del jugador para aplicar la nueva gravedad.
		# Se verifica primero si el método existe, por seguridad.
		if player.has_method("set_gravity_direction"):
			player.set_gravity_direction(new_gravity_dir)
		player.visible = true
