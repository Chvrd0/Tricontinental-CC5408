extends Node2D

var entrada: bool = true
var PORTAL = preload("uid://6xasnqsryygo")
var PORTAL_SALIDA = preload("uid://ccnqpatetrj6x")
const PLAYER = preload("uid://cde78dlgk1acq")

var preparacion1: bool = true
var preparacion2: bool = true

@export var spawn_point: Vector2

func _physics_process(delta: float) -> void:
	if preparacion1:
		
		if Input.is_action_just_pressed("click"):
			if entrada:
				var entrada_inst = PORTAL.instantiate()
				add_child(entrada_inst)
				entrada_inst.global_position = get_global_mouse_position()
				entrada = false
			else:
				var salida_inst = PORTAL_SALIDA.instantiate()
				add_child(salida_inst)
				salida_inst.global_position = get_global_mouse_position()
				entrada = true
		if Input.is_action_just_pressed("jump"):
			preparacion1 = false
	else:
		if preparacion2:
			var player = PLAYER.instantiate()
			player.global_position = spawn_point
			add_child(player)
			preparacion2 = false
