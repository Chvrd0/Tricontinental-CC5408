extends Node2D

var entrada: bool = true
var PORTAL = preload("uid://6xasnqsryygo")
var PORTAL_SALIDA = preload("uid://ccnqpatetrj6x")

func _physics_process(delta: float) -> void:
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
