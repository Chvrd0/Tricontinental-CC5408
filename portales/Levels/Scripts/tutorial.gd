extends "res://Levels/Scripts/base_level.gd"


# Using @export is safer than hardcoding paths ($TutorialUI/...)
@export var tutorial_ui_label: Label 
@onready var coin: Area2D

enum State { INTRO, PLACE_ENTRY, PLACE_EXIT, ROTATE, START, COLLECT }
var current_state = State.INTRO

func _ready():
	super._ready()
	# 1. Force 1 portal pair for the tutorial
	cantidad_portales = 2
	
	# 2. Grab the label if not assigned via Inspector (Fallback)
	if not tutorial_ui_label and has_node("TutorialUI/PanelContainer/Label"):
		tutorial_ui_label = $TutorialUI/PanelContainer/Label
		
	if not coin and has_node("Level1/Coin"):
		coin = $Level1/Coin
		
	update_tutorial_text()

# Use _physics_process to stay in sync with base_level.gd's click logic
func _physics_process(delta):
	super._physics_process(delta)
	
	match current_state:
		State.INTRO:
			# Step 1: Detect movement
			if Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
				current_state = State.PLACE_ENTRY
				update_tutorial_text()
				
		State.PLACE_ENTRY:
			# Step 2: Wait for Entry (Orange) placement
			# When placed, 'entrada' variable in base_level switches to false
			if not entrada:
				current_state = State.PLACE_EXIT
				update_tutorial_text()
				
		State.PLACE_EXIT:
			# Step 3: Wait for Exit (Blue) placement
			# When placed, 'entrada' flips back to true AND count drops to 0
			if entrada:
				current_state = State.ROTATE
				update_tutorial_text()
				
		State.ROTATE:
			# Step 4: Teach Rotation (The user rotates the ghost here)
			if Input.is_action_just_pressed("rotate_right"):
				current_state = State.START
				update_tutorial_text()


		State.START:
			# Step 5: Wait for Player Spawn
			if not preparacion1:
				current_state = State.COLLECT
				update_tutorial_text()
		
		
func update_tutorial_text():
	var text = ""
	print("Updating tutorial state:", State.keys()[current_state])
	
	match current_state:
		State.INTRO:
			text = "Welcome! Use WASD/Arrows to move the camera."
		State.PLACE_ENTRY:
			text = "Click to place the ENTRY (Orange) portal."
		State.PLACE_EXIT:
			text = "Now click to place the EXIT (Blue) portal nearby."
		State.ROTATE:
			text = "Portals placed! Press [R] to see how rotation works (changes gravity!)."
		State.START:
			text = "Ready! Press [SPACE] to spawn the character."
		State.COLLECT:
			text = "Collect the coin to finish the tutorial!"
	
	if tutorial_ui_label:
		tutorial_ui_label.text = text
