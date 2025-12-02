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

# --- COLORES DEFINIDOS ---
var COLOR_ENTRADA = Color("ff7700") # Orange
var COLOR_SALIDA = Color("0099ff")  # Blue

# ===========================
# ==== REFERENCIAS DE NODOS ==
# ===========================

@onready var camera: CharacterBody2D = $Camera
@onready var portal_fantasma: Node2D = $PortalFantasma
@onready var counter: Label = $Counter

var ghost_arrow_ref: Node2D

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
	var ArrowScript = load("res://Levels/Scripts/gravity_arrow.gd")
	if ArrowScript:
		ghost_arrow_ref = ArrowScript.new()
		if portal_fantasma:
			portal_fantasma.add_child(ghost_arrow_ref)
			ghost_arrow_ref.visible = false 
	update_portal_ui()

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		print("PAUSING ---------------------------------")
		var pause_menu_instance = PAUSE_MENU.instantiate()
		add_child(pause_menu_instance)
		
	if is_instance_valid(ghost_arrow_ref):
		ghost_arrow_ref.visible = (not entrada) and preparacion1

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
		# 1. Posicionamiento por defecto (donde está el mouse)
		portal_fantasma.global_position = mouse

		# 2. Lógica de CLAMP (Restricción) si es una SALIDA
		if not entrada:
			var entradas = get_tree().get_nodes_in_group("portalEntrada")
			if entradas.size() > 0:
				var entrada_act: Vector2 = entradas[-1].global_position
				var max_d: Vector2 = mouse - entrada_act
				var distance: float = max_d.length()
				var direcc: Vector2 = max_d.normalized()
				
				# Aplicamos el límite visualmente
				var limit: float = clamp(distance, min_dist, max_dist)
				portal_fantasma.global_position = entrada_act + (direcc * limit)

		# 3. Rotación
		if Input.is_action_just_pressed("rotate_right"):
			portal_fantasma.rotate(rotation_step)
		
		# 4. Color
		var color_actual = COLOR_ENTRADA if entrada else COLOR_SALIDA
		_aplicar_color_invertido(portal_fantasma, portal_fantasma.rotation, color_actual)

		# ======================
		# Colocación de portales
		# ======================
		if Input.is_action_just_pressed("click"):
			if cantidad_portales > 0:
				if entrada:
					# --- Colocar Entrada ---
					var entrada_inst = PORTAL.instantiate()
					add_child(entrada_inst)
					entrada_inst.global_position = portal_fantasma.global_position # Usamos la pos del fantasma
					entrada_inst.rotation = portal_fantasma.rotation
					
					_aplicar_color_invertido(entrada_inst, portal_fantasma.rotation, COLOR_ENTRADA)
					
					entrada = false
				else:
					# --- Colocar Salida ---
					# Ya calculamos la posición válida arriba (en el bloque fantasma),
					# así que podemos usar portal_fantasma.global_position directamente.
					
					var salida_inst = PORTAL_SALIDA.instantiate()
					add_child(salida_inst)

					salida_inst.global_position = portal_fantasma.global_position
					salida_inst.rotation = portal_fantasma.rotation
					
					_aplicar_color_invertido(salida_inst, portal_fantasma.rotation, COLOR_SALIDA)

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

func _aplicar_color_invertido(nodo: Node2D, rotacion: float, color_base: Color) -> void:
	nodo.modulate = color_base

func update_portal_ui() -> void:
	if counter:
		counter.text = "Portal count: " + str(cantidad_portales)
