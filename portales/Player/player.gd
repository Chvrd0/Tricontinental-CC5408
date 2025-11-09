class_name Player
extends CharacterBody2D


# ===========================
# ==== VARIABLES EXPORTADAS ====
# ===========================

## Velocidad máxima de desplazamiento horizontal (en píxeles/segundo)
@export var max_speed: float = 140

## Velocidad de salto (magnitud inicial de la velocidad al saltar)
@export var jump_speed: float = 190

## Intensidad de la fuerza gravitacional que afecta al jugador
@export var gravity_force: float = 500

## Vector que indica la dirección de la gravedad (por defecto, hacia abajo)
var gravity_direction: Vector2 = Vector2.DOWN

## Aceleración horizontal que define la rapidez con que el jugador alcanza su velocidad objetivo
@export var acceleration: float = 2000


# ===========================
# ==== REFERENCIAS DE NODOS ====
# ===========================

## Referencia al cuerpo físico del jugador
@onready var player: CharacterBody2D = $"." 

## Colisionador del cuerpo del jugador (para detectar colisiones)
@onready var player_body: CollisionShape2D = $player_body

## Nodo que actúa como pivote para girar el sprite según la dirección
@onready var pivot: Node2D = $pivot

## Sprite visual del jugador, hijo del nodo pivot
@onready var sprite_2d: Sprite2D = $pivot/Sprite2D

## Controlador de animaciones individuales
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## Árbol de animaciones que maneja los estados (idle, move, jump, etc.)
@onready var animation_tree: AnimationTree = $AnimationTree

## Reproductor de animaciones actual del árbol (permite cambiar de estado)
@onready var playback = animation_tree["parameters/playback"]


# ===========================
# ==== FUNCIONES PRINCIPALES ====
# ===========================

## Inicialización del jugador al entrar en el árbol de la escena
func _ready() -> void:
	add_to_group("player")  # Permite identificar al jugador desde otros scripts
	
	# --- NUEVA LÍNEA ---
	# Establece la rotación inicial del jugador en base a la dirección de gravedad actual
	actualizar_rotacion_visual()


## Se ejecuta en cada frame de física (60 fps por defecto)
## Controla gravedad, movimiento, salto y animaciones.
func _physics_process(delta: float) -> void:
	# ====== APLICAR GRAVEDAD ======
	if not is_on_floor():
		velocity += gravity_direction * gravity_force * delta

	# ====== MOVIMIENTO HORIZONTAL ======
	var move_input := Input.get_axis("move_left", "move_right")
	
	# Vector horizontal perpendicular a la gravedad (eje “suelo”)
	var right_vector := gravity_direction.orthogonal()
	
	# Velocidad objetivo según la dirección del input
	var target_velocity := right_vector * move_input * max_speed
	
	# Componente actual de la velocidad a lo largo del “suelo”
	var current_floor_velocity := velocity.project(right_vector)
	
	# Interpolación suave hacia la velocidad objetivo
	var new_floor_velocity := current_floor_velocity.move_toward(target_velocity, acceleration * delta)
	
	# Se actualiza la velocidad total del jugador
	velocity = velocity - current_floor_velocity + new_floor_velocity
	
	# Define la dirección “arriba” del cuerpo (necesario para colisiones)
	self.up_direction = -gravity_direction
	move_and_slide()
	self.up_direction = -gravity_direction
	
	# ====== ANIMACIONES ======
	if current_floor_velocity.length() > 10:
		playback.travel("move")
	else:
		playback.travel("idle")
		
	# Gira el sprite según la dirección del movimiento
	if move_input:
		pivot.scale.x = sign(move_input)

	# ====== SALTO ======
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity = -gravity_direction * jump_speed


# ===========================
# ==== FUNCIONES DE GRAVEDAD ====
# ===========================

## Cambia la dirección de la gravedad del jugador.
## Generalmente llamada desde un portal u otro objeto del nivel.
##
## @param new_direction Vector2 - Nueva dirección de gravedad.
func set_gravity_direction(new_direction: Vector2) -> void:
	gravity_direction = new_direction.normalized()
	self.up_direction = -gravity_direction
	
	# Actualiza la rotación del jugador para coincidir con la nueva dirección
	actualizar_rotacion_visual()


## Ajusta la rotación visual del jugador según la dirección de gravedad actual.
## Esto asegura que el sprite "mire hacia arriba" respecto a su nueva orientación.
func actualizar_rotacion_visual() -> void:
	# Rotamos el nodo completo (CharacterBody2D)
	# Calculamos el ángulo del vector “arriba” (-gravity_direction)
	# y le sumamos 90 grados (PI/2) porque la rotación cero apunta hacia la derecha.
	self.rotation = (-gravity_direction).angle() + (PI / 2)
