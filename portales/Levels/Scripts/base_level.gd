extends Node2D

var entrada: bool = true
var PORTAL = preload("uid://6xasnqsryygo")
var PORTAL_SALIDA = preload("uid://ccnqpatetrj6x")
const PLAYER = preload("uid://cde78dlgk1acq")

@onready var camera: CharacterBody2D = $Camera
@onready var portal_fantasma: Node2D = $PortalFantasma

@export var max_speed = 140
@export var acceleration = 2000

var preparacion1: bool = true
var preparacion2: bool = true

@export var spawn_point: Vector2
@export var cantidad_portales: int

func _physics_process(delta: float) -> void:
	if preparacion1:
		var mouse = get_global_mouse_position()
		var x_input = Input.get_axis("move_left","move_right")
		var y_input = Input.get_axis("move_up","move_down")
		camera.velocity.x = move_toward(camera.velocity.x, x_input*max_speed,acceleration*delta)
		camera.velocity.y = move_toward(camera.velocity.y, y_input*max_speed,acceleration*delta)
		camera.move_and_slide()
		
		portal_fantasma.global_position = mouse
		
		if Input.is_action_just_pressed("click"):
			if cantidad_portales > 0:
				if entrada:
					var entrada_inst = PORTAL.instantiate()
					add_child(entrada_inst)
					entrada_inst.global_position = mouse
					entrada = false
				else:
					var salida_inst = PORTAL_SALIDA.instantiate()
					add_child(salida_inst)
					salida_inst.global_position = mouse
					entrada = true
					cantidad_portales -= 1
				
		if Input.is_action_just_pressed("jump"):
			preparacion1 = false
	else:
		portal_fantasma.hide()
		if preparacion2:
			var player = PLAYER.instantiate()
			player.global_position = spawn_point
			add_child(player)
			preparacion2 = false
