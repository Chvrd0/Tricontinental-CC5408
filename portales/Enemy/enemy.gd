class name Biter
extends CharacterBody2D   

@export var speed: float = 70      

@export var left_limit: float = -50.0
@export var right_limit: float = 50.0   
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var gravity = 500

var direction: int = 1
var start_x: float

func _ready():
	start_x = global_position.x
	animated_sprite_2d.play("move")
	


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	velocity.x = direction * speed
	move_and_slide()

	animated_sprite_2d.flip_h = direction < 0

	var distance_from_start = global_position.x - start_x
	if distance_from_start > right_limit:
		direction = -1
	elif distance_from_start < left_limit:
		direction = 1


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player touched!")
		get_tree().reload_current_scene()
		
