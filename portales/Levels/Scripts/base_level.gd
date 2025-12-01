extends Node2D

# ===========================
# ==== VARIABLES GLOBALES ====
# ===========================

## Indica si el próximo portal a colocar es una entrada (true) o una salida (false).
var entrada: bool = true

## Escena del portal de entrada.
var PORTAL = preload("uid://6xasnqsryygo") # Asegúrate que estas rutas sean correctas en tu proyecto
## Escena del portal de salida.
var PORTAL_SALIDA = preload("uid://ccnqpatetrj6x")
## Escena del jugador.
const PLAYER = preload("uid://cde78dlgk1acq")
const PAUSE_MENU = preload("res://menus/pause_menu.tscn")

# ===========================
# ==== REFERENCIAS DE NODOS ==
# ===========================

@onready var camera: CharacterBody2D = $Camera
@onready var portal_fantasma: Node2D = $PortalFantasma
@onready var counter: Label = $Counter


# ===========================
# ==== PARÁMETROS EXPORTADOS ==
# ===========================

@export var max_speed: float = 140
@export var acceleration: float = 2000

# ===========================
# ==== ESTADO DE PREPARACIÓN ==
# ===========================

var preparacion1: bool = true
var preparacion2: bool = true

# ===========================
# ==== CONFIGURACIÓN DEL NIVEL ==
# ===========================

@export var spawn_point_node: NodePath
var spawn_position: Vector2 = Vector2.ZERO
@export var cantidad_portales: int
@export var min_dist: float = 50.0
@export var max_dist: float = 300.0

# ===========================
# ==== ROTACIÓN DE PORTALES ====
# ===========================

var rotation_step: float = PI / 2

# ===========================
# ==== FUNCIONES DE GODOT ====
# ===========================

func _ready() -> void:
	if not spawn_point_node.is_empty():
		if has_node(spawn_point_node):
			var spawn_node: Node2D = get_node(spawn_point_node)
			spawn_position = spawn_node.global_position
		else:
			push_error("Spawn point node not found at path: " + str(spawn_point_node))
			spawn_position = Vector2.ZERO
	else:
		push_warning("Spawn point node not assigned. Spawning at (0,0).")
		spawn_position = Vector2.ZERO
	update_portal_ui()

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		print("PAUSING ---------------------------------")
		var pause_menu_instance = PAUSE_MENU.instantiate()
		add_child(pause_menu_instance)

# ===========================
# ==== LÓGICA PRINCIPAL =======
# ===========================

func _physics_process(delta: float) -> void:
	if preparacion1:
		# ======================
		# Movimiento de cámara
		# ======================
		var mouse := get_global_mouse_position()
		var x_input := Input.get_axis("move_left", "move_right")
		var y_input := Input.get_axis("move_up", "move_down")

		camera.velocity.x = move_toward(camera.velocity.x, x_input * max_speed, acceleration * delta)
		camera.velocity.y = move_toward(camera.velocity.y, y_input * max_speed, acceleration * delta)
		camera.move_and_slide()

		# ======================	
		# Portal fantasma
		# ======================
		portal_fantasma.global_position = mouse

		if Input.is_action_just_pressed("rotate_right"):
			portal_fantasma.rotate(rotation_step)
		
		# ## <--- NUEVO: Actualizamos el color del fantasma en tiempo real
		_aplicar_color_invertido(portal_fantasma, portal_fantasma.rotation)

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
					
					## Aplicar color al instanciar
					_aplicar_color_invertido(entrada_inst, portal_fantasma.rotation)
					
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
					
					# ## <--- NUEVO: Aplicar color al instanciar
					_aplicar_color_invertido(salida_inst, portal_fantasma.rotation)

					entrada = true
					cantidad_portales -= 1
					
					update_portal_ui()
					portal_fantasma.rotation = 0.0

		# ======================
		# Salir de la fase de preparación
		# ======================
		if Input.is_action_just_pressed("jump"):
			preparacion1 = false
	else:
		portal_fantasma.hide()

		if preparacion2:
			var player = PLAYER.instantiate()
			player.global_position = spawn_position
			add_child(player)
			camera.queue_free()
			preparacion2 = false

# ===========================
# ==== FUNCIONES AUXILIARES ====
# ===========================

## Verifica la rotación y cambia el color si está invertido (180 grados).
func _aplicar_color_invertido(nodo: Node2D, rotacion: float) -> void:
	# Normalizamos la rotación a un rango de 0 a 2*PI (0 a 360 grados)
	# para evitar problemas si rotas muchas veces.
	var rot_norm = wrapf(rotacion, 0, TAU)
	
	# PI es 180 grados. Usamos is_equal_approx porque los floats nunca son exactos.
	# Si está rotado 180 grados (mirando abajo/invertido en Y localmente):
	if is_equal_approx(rot_norm, PI):
		# Opción A: Inversión matemática de color (ej. blanco -> negro)
		nodo.modulate = Color(0, 1, 1).inverted()
	elif is_equal_approx(rot_norm, 0.5*PI):
		nodo.modulate = Color(1, 0.6, 0)
	elif is_equal_approx(rot_norm, 1.5*PI):
		nodo.modulate = Color(1, 0.6, 0).inverted()
	else:
		# Si no está invertido, color normal (blanco / original)
		nodo.modulate = Color(1, 1, 1)

func update_portal_ui() -> void:
	if counter:
		counter.text = "Portal count: " + str(cantidad_portales)
