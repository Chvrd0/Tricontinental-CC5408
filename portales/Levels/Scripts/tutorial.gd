extends "res://Levels/Scripts/base_level.gd"

@export var tutorial_ui_label: Label 
@onready var coin: Area2D

# Added FREE_PLACEMENT state to allow adding more portals before starting
enum State { INTRO, PLACE_ENTRY_1, PLACE_EXIT_1, ROTATE_TUTORIAL, FREE_PLACEMENT, COLLECT }
var current_state = State.INTRO

func _ready():
	super._ready()
	# 1. Allow 2 pairs so they can practice the gravity mechanic
	cantidad_portales = 2
	
	if not tutorial_ui_label and has_node("TutorialUI/PanelContainer/Label"):
		tutorial_ui_label = $TutorialUI/PanelContainer/Label
	
	if not coin and has_node("Level1/Coin"):
		coin = $Level1/Coin
		
	# Ensure ghost is visible
	if portal_fantasma:
		portal_fantasma.z_index = 100
		portal_fantasma.show()
		
	update_tutorial_text()

func _physics_process(delta):
	# 1. Always handle Camera & Ghost (Visuals)
	_handle_camera_movement(delta)
	_handle_ghost_update()

	# 2. State Machine
	match current_state:
		State.INTRO:
			if Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
				current_state = State.PLACE_ENTRY_1
				update_tutorial_text()
				
		State.PLACE_ENTRY_1:
			if Input.is_action_just_pressed("click"):
				_place_entry_portal()
				current_state = State.PLACE_EXIT_1
				update_tutorial_text()
				
		State.PLACE_EXIT_1:
			if Input.is_action_just_pressed("click"):
				_place_exit_portal()
				current_state = State.ROTATE_TUTORIAL
				update_tutorial_text()
				
		State.ROTATE_TUTORIAL:
			# Force them to rotate at least once to learn the mechanic
			if Input.is_action_just_pressed("rotate_right"):
				_rotate_ghost()
				current_state = State.FREE_PLACEMENT
				update_tutorial_text()

		State.FREE_PLACEMENT:
			# Here we allow full freedom: Rotate, Place, or Start
			
			# A. Rotate
			if Input.is_action_just_pressed("rotate_right"):
				_rotate_ghost()
				
			# B. Place more portals (if available)
			if Input.is_action_just_pressed("click") and cantidad_portales > 0:
				if entrada:
					_place_entry_portal()
				else:
					_place_exit_portal()
			
			# C. Spawn / Start Game
			if Input.is_action_just_pressed("jump"):
				_spawn_player_custom()
				current_state = State.COLLECT
				update_tutorial_text()
		
		State.COLLECT:
			portal_fantasma.hide()

# --- Helpers ---

func _handle_camera_movement(delta):
	if is_instance_valid(camera):
		var x_input := Input.get_axis("move_left", "move_right")
		var y_input := Input.get_axis("move_up", "move_down")
		camera.velocity.x = move_toward(camera.velocity.x, x_input * max_speed, acceleration * delta)
		camera.velocity.y = move_toward(camera.velocity.y, y_input * max_speed, acceleration * delta)
		camera.move_and_slide()

func _handle_ghost_update():
	if current_state == State.COLLECT: return
	
	var mouse = get_global_mouse_position()
	
	# Clamp distance logic for Exits
	if (current_state == State.PLACE_EXIT_1 or (current_state == State.FREE_PLACEMENT and not entrada)):
		var portals = get_tree().get_nodes_in_group("portalEntrada")
		if portals.size() > 0:
			var entrada_act = portals[-1].global_position
			var max_d = mouse - entrada_act
			var distance = max_d.length()
			var direcc = max_d.normalized()
			var limit = clamp(distance, min_dist, max_dist)
			portal_fantasma.global_position = entrada_act + (direcc * limit)
		else:
			portal_fantasma.global_position = mouse
	else:
		portal_fantasma.global_position = mouse
	
	_aplicar_color_invertido(portal_fantasma, portal_fantasma.rotation)

func _rotate_ghost():
	portal_fantasma.rotate(rotation_step)
	_aplicar_color_invertido(portal_fantasma, portal_fantasma.rotation)

func _place_entry_portal():
	var entrada_inst = PORTAL.instantiate()
	add_child(entrada_inst)
	entrada_inst.global_position = portal_fantasma.global_position
	entrada_inst.rotation = portal_fantasma.rotation
	_aplicar_color_invertido(entrada_inst, portal_fantasma.rotation)
	entrada = false 

func _place_exit_portal():
	var salida_inst = PORTAL_SALIDA.instantiate()
	add_child(salida_inst)
	salida_inst.global_position = portal_fantasma.global_position
	salida_inst.rotation = portal_fantasma.rotation
	_aplicar_color_invertido(salida_inst, portal_fantasma.rotation)
	entrada = true
	cantidad_portales -= 1
	update_portal_ui()
	portal_fantasma.rotation = 0.0

func _spawn_player_custom():
	portal_fantasma.hide()
	preparacion1 = false
	preparacion2 = false
	var player = PLAYER.instantiate()
	player.global_position = spawn_position
	add_child(player)
	if is_instance_valid(camera):
		camera.queue_free()

func update_tutorial_text():
	var text = ""
	var key_rotate = get_input_label("rotate_right")
	var key_spawn = get_input_label("jump")
	
	match current_state:
		State.INTRO:
			text = "Welcome! Use WASD/Arrows to move the camera."
		State.PLACE_ENTRY_1:
			text = "Click to place the FIRST Entry (Orange)."
		State.PLACE_EXIT_1:
			text = "Click to place the FIRST Exit (Blue)."
		State.ROTATE_TUTORIAL:
			text = "Press %s to Rotate the portal. This INVERTS gravity!" % key_rotate
		State.FREE_PLACEMENT:
			# Updated Hint Text
			text = "HINT: You NEED gravity inversion to solve this level!\nPlace more portals if you want, or Press %s to Start." % key_spawn
		State.COLLECT:
			text = "Collect the coin to finish!"
	
	if tutorial_ui_label:
		tutorial_ui_label.text = text

func get_input_label(action_name: String) -> String:
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		var label = events[0].as_text()
		return "[" + label.split(" (")[0] + "]"
	return "[" + action_name + "]"
