## base_level.gd
##
## Nodo controlador de la fase de preparación inicial del nivel.
## Permite:
##  - Mover una cámara libremente por el mapa.
##  - Posicionar pares de portales (entrada y salida) usando el mouse.
##  - Rotar los portales antes de colocarlos.
##  - Spawnear al jugador en un nodo definido una vez terminada la preparación.


extends Node2D


# ===========================
# ==== VARIABLES GLOBALES ====
# ===========================

## Indica si el próximo portal a colocar es una entrada (true) o una salida (false).
var entrada: bool = true

## Escena del portal de entrada.
var PORTAL = preload("uid://6xasnqsryygo")

## Escena del portal de salida.
var PORTAL_SALIDA = preload("uid://ccnqpatetrj6x")

## Escena del jugador.
const PLAYER = preload("uid://cde78dlgk1acq")


# ===========================
# ==== REFERENCIAS DE NODOS ==
# ===========================

## Cámara que se mueve libremente durante la fase de preparación.
@onready var camera: CharacterBody2D = $Camera

## Portal “fantasma” que se muestra donde está el mouse para previsualizar
## la posición y rotación antes de colocar el portal real.
@onready var portal_fantasma: Node2D = $PortalFantasma


# ===========================
# ==== PARÁMETROS EXPORTADOS ==
# ===========================

## Velocidad máxima de movimiento de la cámara en preparación.
@export var max_speed: float = 140

## Aceleración de la cámara al moverse.
@export var acceleration: float = 2000


# ===========================
# ==== ESTADO DE PREPARACIÓN ==
# ===========================

## Indica si estamos en la primera etapa de preparación:
## - mover cámara
## - colocar portales
## - decidir cuándo comenzar la partida.
var preparacion1: bool = true

## Indica si ya se ha instanciado el jugador o no (para que se cree una sola vez).
var preparacion2: bool = true


# ===========================
# ==== CONFIGURACIÓN DEL NIVEL ==
# ===========================

## Nodo (Marker2D) que define dónde aparecerá el jugador.
@export var spawn_point_node: NodePath

## Almacena la posición del nodo de spawn para usarla luego.
var spawn_position: Vector2 = Vector2.ZERO  ## <-- ADDED (fixes the errors)

## Cantidad de pares de portales disponibles para colocar.
@export var cantidad_portales: int

## Distancia mínima entre el portal de entrada y el portal de salida.
@export var min_dist: float = 50.0

## Distancia máxima entre el portal de entrada y el portal de salida.
@export var max_dist: float = 300.0


# ===========================
# ==== ROTACIÓN DE PORTALES ====
# ===========================

## Ángulo de rotación a aplicar cada vez que el usuario presiona la acción "rotate_right".
## PI/2 equivale a 90 grados.
var rotation_step: float = PI / 2



# ===========================
# ==== FUNCIONES DE GODOT ====
# ===========================

## Se llama una vez cuando el nodo entra en la escena.
func _ready() -> void:
	# Verificamos si el NodePath de spawn_point_node ha sido asignado en el editor.
	if not spawn_point_node.is_empty():
		# Nos aseguramos de que el nodo exista en la escena antes de intentar acceder a él.
		if has_node(spawn_point_node):
			# Obtenemos el nodo real (que debe ser un Node2D o derivado).
			var spawn_node: Node2D = get_node(spawn_point_node)
			# Guardamos su posición global para usarla al spawnear al jugador.
			spawn_position = spawn_node.global_position
		else:
			# El NodePath fue asignado pero el nodo no se encontró (error en la escena).
			push_error("Spawn point node not found at path: " + str(spawn_point_node))
			spawn_position = Vector2.ZERO # Fallback para evitar crasheo.
	else:
		# El NodePath no fue asignado en el Inspector.
		push_warning("Spawn point node not assigned in BaseLevel script. Spawning at (0,0).")
		spawn_position = Vector2.ZERO # Fallback para evitar crasheo.



# ===========================
# ==== LÓGICA PRINCIPAL =======
# ===========================

## Proceso de física principal.
## Mientras `preparacion1` es true:
##   - Se mueve la cámara según input.
##   - Se actualiza la posición del portal fantasma al mouse.
##   - Se permiten colocar portales y rotarlos.
## Cuando `preparacion1` pasa a false:
##   - Se esconde el portal fantasma.
##   - Se instancia al jugador en `spawn_position` (una sola vez).
func _physics_process(delta: float) -> void:
	if preparacion1:
		# ======================
		# Movimiento de cámara
		# ======================
		var mouse := get_global_mouse_position()
		var x_input := Input.get_axis("move_left", "move_right")
		var y_input := Input.get_axis("move_up", "move_down")

		# Suavizado de movimiento en X e Y usando move_toward
		camera.velocity.x = move_toward(camera.velocity.x, x_input * max_speed, acceleration * delta)
		camera.velocity.y = move_toward(camera.velocity.y, y_input * max_speed, acceleration * delta)
		camera.move_and_slide()

		# ======================
		# Portal fantasma
		# ======================
		portal_fantasma.global_position = mouse

		if Input.is_action_just_pressed("rotate_right"):
			portal_fantasma.rotate(rotation_step)

		# ======================
		# Colocación de portales
		# ======================
		if Input.is_action_just_pressed("click"):
			if cantidad_portales > 0:
				if entrada:
					var entrada_inst = PORTAL.instantiate()
					add_child(entrada_inst)
					entrada_inst.global_position = mouse
					entrada_inst.rotation = portal_fantasma.rotation
					entrada = false
				else:
					var entrada_act: Vector2 = get_tree().get_nodes_in_group("portalEntrada")[-1].global_position
					var max_d: Vector2 = mouse - entrada_act
					var distance: float = max_d.length()
					var direcc: Vector2 = max_d.normalized()
					var limit: float = clamp(distance, min_dist, max_dist)

					portal_fantasma.global_position = entrada_act + (direcc * limit)

					var salida_inst = PORTAL_SALIDA.instantiate()
					add_child(salida_inst)

					salida_inst.global_position = portal_fantasma.global_position
					salida_inst.rotation = portal_fantasma.rotation

					entrada = true
					cantidad_portales -= 1
					portal_fantasma.rotation = 0.0

		# ======================
		# Salir de la fase de preparación
		# ======================
		if Input.is_action_just_pressed("jump"):
			preparacion1 = false
	else:
		# Ocultamos el portal fantasma cuando ya no estamos en modo preparación.
		portal_fantasma.hide()

		# Instanciamos al jugador una sola vez en el punto de spawn.
		if preparacion2:
			var player = PLAYER.instantiate()
			player.global_position = spawn_position
			add_child(player)
			camera.queue_free()
			preparacion2 = false
