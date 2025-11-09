class_name Player
extends CharacterBody2D
@export var max_speed = 140
@export var jump_speed = 190
@export var gravity_force = 500
var gravity_direction: Vector2 = Vector2.DOWN
@export var acceleration = 2000

@onready var player: CharacterBody2D = $"."
@onready var player_body: CollisionShape2D = $player_body
@onready var pivot: Node2D = $pivot
@onready var sprite_2d: Sprite2D = $pivot/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]


func _ready():
	add_to_group("player")
	# --- NUEVA LÍNEA ---
	# Establece la rotación inicial basada en la gravedad inicial
	actualizar_rotacion_visual()

func _physics_process(delta: float) -> void:
	# --- (SECCIÓN DE GRAVEDAD de la respuesta anterior) ---
	if not is_on_floor():
		velocity += gravity_direction * gravity_force * delta

	# --- (SECCIÓN DE MOVIMIENTO de la respuesta anterior) ---
	var move_input = Input.get_axis("move_left","move_right")
	var right_vector = gravity_direction.orthogonal() 
	var target_velocity = right_vector * move_input * max_speed
	var current_floor_velocity = velocity.project(right_vector)
	var new_floor_velocity = current_floor_velocity.move_toward(target_velocity, acceleration * delta)
	velocity = velocity - current_floor_velocity + new_floor_velocity
	
	self.up_direction = -gravity_direction 
	move_and_slide()
	self.up_direction = -gravity_direction
	
	# Lógica de animación (sin cambios)
	if (current_floor_velocity.length() > 10):
		playback.travel("move")
	else:
		playback.travel("idle")
		
	if move_input:
		pivot.scale.x = sign(move_input) # Esto ahora funciona relativo al jugador

	# --- (SECCIÓN DE SALTO de la respuesta anterior) ---
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity = -gravity_direction * jump_speed


# --- FUNCIÓN MODIFICADA ---
# Esta función es llamada por el portal
func set_gravity_direction(new_direction: Vector2):
	gravity_direction = new_direction.normalized()
	self.up_direction = -gravity_direction
	# --- NUEVA LÍNEA ---
	# Llama a la función que actualiza la rotación visual
	actualizar_rotacion_visual()

# --- NUEVA FUNCIÓN ---
# Creamos una función separada para actualizar la rotación
func actualizar_rotacion_visual():
	# Rotamos 'self' (el CharacterBody2D)
	# Calculamos el ángulo de nuestro vector "arriba" (-gravity_direction)
	# y le sumamos 90 grados (PI/2) porque la rotación 0 de un nodo
	# apunta hacia la "derecha" (Vector2.RIGHT), no hacia "arriba".
	self.rotation = (-gravity_direction).angle() + (PI / 2)
