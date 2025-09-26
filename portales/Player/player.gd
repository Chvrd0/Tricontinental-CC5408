class_name Player
extends CharacterBody2D
@export var max_speed = 140
@export var jump_speed = 250
@export var gravity = 500
@export var acceleration = 2000

@onready var player: CharacterBody2D = $"."
@onready var player_body: CollisionShape2D = $player_body
@onready var pivot: Node2D = $pivot
@onready var sprite_2d: Sprite2D = $pivot/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]

func _physics_process(delta: float) -> void:
	#MOVIMIENTO HORIZONTAL
	var move_input = Input.get_axis("move_left","move_right")
	velocity.x = move_toward(velocity.x, move_input*max_speed,acceleration*delta)
	move_and_slide()
	if (move_input or (velocity.x)>10):
		playback.travel("move")
	else:
		playback.travel("idle")
	if move_input:
		pivot.scale.x = sign(move_input)
	#SALTO
	if not is_on_floor():
		velocity.y += gravity*delta
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += -jump_speed
		
